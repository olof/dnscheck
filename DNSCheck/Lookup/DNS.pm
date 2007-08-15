#!/usr/bin/perl
#
# $Id$
#
# Copyright (c) 2007 .SE (The Internet Infrastructure Foundation).
#                    All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
# IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY
# DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
# GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER
# IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
# OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN
# IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
######################################################################

package DNSCheck::Lookup::DNS;

require 5.8.0;
use warnings;
use strict;

use List::Util 'shuffle';

use Data::Dumper;
use Net::DNS;

######################################################################

sub new {
    my $proto = shift;
    my $class = ref($proto) || $proto;
    my $self  = {};

    $self->{logger} = shift;

    $self->{debug} = 0;

    $self->{resolver} = new Net::DNS::Resolver;
    $self->{resolver}->persistent_tcp(0);
    $self->{resolver}->debug($self->{debug});

    # hash PACKET at resolver indexed by QNAME,QTYPE,QCLASS
    $self->{cache}{resolver} = ();

    # hash PACKET at parent indexed by QNAME,QTYPE,QCLASS
    $self->{cache}{parent} = ();

    # hash PACKET at child indexed by QNAME,QTYPE,QCLASS
    $self->{cache}{child} = ();

    # hash of NAMESERVERS index QNAME,QCLASS,PROTOCOL
    $self->{nameservers} = ();

    # hash of PARENT indexed by CHILD,QCLASS
    $self->{parent} = ();

    bless $self, $class;
}

sub DESTROY {

}

######################################################################

sub query_resolver {
    my $self = shift;

    my $qname  = shift;
    my $qclass = shift;
    my $qtype  = shift;

    $self->{logger}->debug("DNS:QUERY_RESOLVER", $qname, $qclass, $qtype);

    unless ($self->{cache}{resolver}{$qname}{$qclass}{$qtype}) {
        $self->{cache}{resolver}{$qname}{$qclass}{$qtype} =
          $self->{resolver}->send($qname, $qtype, $qclass);
    }

    my $packet = $self->{cache}{resolver}{$qname}{$qclass}{$qtype};

    $self->{logger}->debug("DNS:RESOLVER_RESPONSE",
        sprintf("%d answer(s)", $packet->header->ancount));

    return $packet;
}

######################################################################

sub query_parent {
    my $self   = shift;
    my $qname  = shift;
    my $qclass = shift;
    my $qtype  = shift;

    $self->{logger}->debug("DNS:QUERY_PARENT", $qname, $qclass, $qtype);

    unless ($self->{cache}{parent}{$qname}{$qclass}{$qtype}) {
        $self->{cache}{parent}{$qname}{$qclass}{$qtype} =
          $self->_query_parent_helper($qname, $qclass, $qtype);
    }

    my $packet = $self->{cache}{parent}{$qname}{$qclass}{$qtype};

    $self->{logger}->debug(
        "DNS:PARENT_RESPONSE",
        sprintf(
            "%d answer(s), %d authority",
            $packet->header->ancount, $packet->header->nscount
        )
    );

    return $packet;
}

sub _query_parent_helper {
    my $self   = shift;
    my $qname  = shift;
    my $qclass = shift;
    my $qtype  = shift;

    # find parent
    my $parent = $self->find_parent($qname, $qclass);
    unless ($parent) {
        $self->{logger}->error("DNS:NO_PARENT", $qname, $qclass);
        return undef;
    } else {
        $self->{logger}->debug("DNS:PARENT_OF", $qname, $qclass, $parent);
    }

    # initialize parent nameservers
    $self->init_nameservers($parent, $qclass, $qtype);

    # find possible targets to query
    my @target = ();
    @target = (@target, @{ $self->{nameservers}{$parent}{$qclass}{ipv4} });
    @target = (@target, @{ $self->{nameservers}{$parent}{$qclass}{ipv6} });
    unless (scalar @target) {
        $self->{logger}->error("DNS:NO_PARENT_NS", $qname, $qclass, $parent);
        return undef;
    }

    # randomize name server addresses
    @target = shuffle(@target);

    # set up resolver
    my $resolver = new Net::DNS::Resolver;
    $resolver->debug($self->{debug});
    $resolver->recurse(0);
    $resolver->nameserver(@target);

    return $resolver->send($qname, $qtype, $qclass);
}

######################################################################

sub query_child {

    my $self   = shift;
    my $qname  = shift;
    my $qclass = shift;
    my $qtype  = shift;

    $self->{logger}->debug("DNS:QUERY_CHILD", $qname, $qclass, $qtype);

    unless ($self->{cache}{child}{$qname}{$qclass}{$qtype}) {
        $self->{cache}{child}{$qname}{$qclass}{$qtype} =
          $self->_query_child_helper($qname, $qclass, $qtype);
    }

    my $packet = $self->{cache}{child}{$qname}{$qclass}{$qtype};

    $self->{logger}->debug("DNS:CHILD_RESPONSE",
        sprintf("%d answer(s)", $packet->header->ancount));

    return $packet;

}

sub _query_child_helper {
    my $self   = shift;
    my $qname  = shift;
    my $qclass = shift;
    my $qtype  = shift;

    # initialize child nameservers
    $self->init_nameservers($qname, $qclass, $qtype);

    # find possible targets to query
    my @target = ();
    @target = (@target, @{ $self->{nameservers}{$qname}{$qclass}{ipv4} });
    @target = (@target, @{ $self->{nameservers}{$qname}{$qclass}{ipv6} });
    unless (scalar @target) {
        $self->{logger}->error("DNS:NO_CHILD_NS", $qname, $qclass);
        return undef;
    }

    # randomize name server addresses
    @target = shuffle(@target);

    # set up resolver
    my $resolver = new Net::DNS::Resolver;
    $resolver->debug($self->{debug});
    $resolver->recurse(0);
    $resolver->nameserver(@target);

    return $resolver->send($qname, $qtype, $qclass);
}

######################################################################

sub query_explicit {
    my $self      = shift;
    my $qname     = shift;
    my $qclass    = shift;
    my $qtype     = shift;
    my $address   = shift;
    my $transport = shift;

	$transport = "udp" unless($transport);

    $self->{logger}->debug("DNS:QUERY_EXPLICIT", $qname, $qclass, $qtype, $address, $transport);

    # set up resolver
    my $resolver = new Net::DNS::Resolver;
    $resolver->debug($self->{debug});
    $resolver->recurse(0);
    $resolver->nameserver($address);

    if ($transport eq "udp") {
        $resolver->usevc(0);
    } elsif ($transport eq "tcp") {
        $resolver->usevc(1);
    } else {
        die "unknown transport";
    }

    my $packet = $resolver->send($qname, $qtype, $qclass);

    $self->{logger}->debug("DNS:EXPLICIT_RESPONSE",
        sprintf("%d answer(s)", $packet->header->ancount));

    return $packet;
}

######################################################################

sub get_nameservers_ipv4 {
    my $self   = shift;
    my $qname  = shift;
    my $qclass = shift;

    $self->init_nameservers($qname, $qclass);

    return $self->{nameservers}{$qname}{$qclass}{ipv4};
}

sub get_nameservers_ipv6 {
    my $self   = shift;
    my $qname  = shift;
    my $qclass = shift;

    $self->init_nameservers($qname, $qclass);

    return $self->{nameservers}{$qname}{$qclass}{ipv6};
}

sub get_nameservers_at_parent {
    my $self   = shift;
    my $qname  = shift;
    my $qclass = shift;

    my @ns;

    my $packet = $self->query_parent($qname, $qclass, "NS");

    foreach my $rr ($packet->authority) {
        if ($rr->type eq "NS") {
            push @ns, $rr->nsdname;
        }
    }

    return sort(@ns);
}

sub get_nameservers_at_child {
    my $self   = shift;
    my $qname  = shift;
    my $qclass = shift;

    my @ns;

    my $packet = $self->query_child($qname, $qclass, "NS");

    foreach my $rr ($packet->answer) {
        if ($rr->type eq "NS") {
            push @ns, $rr->nsdname;
        }
    }

    return sort(@ns);
}

######################################################################

sub init_nameservers {
    my $self   = shift;
    my $qname  = shift;
    my $qclass = shift;

    unless ($self->{nameservers}{$qname}{$qclass}{ns}) {
        $self->_init_nameservers($qname, $qclass);
    }
}

sub _init_nameservers {
    my $self   = shift;
    my $qname  = shift;
    my $qclass = shift;

    $self->{nameservers}{$qname}{$qclass}{ns}   = ();
    $self->{nameservers}{$qname}{$qclass}{ipv4} = ();
    $self->{nameservers}{$qname}{$qclass}{ipv6} = ();

    # Lookup name servers
    my $parent_ns = $self->query_resolver($qname, $qclass, "NS");
    foreach my $rr ($parent_ns->answer) {
        if ($rr->type eq "NS") {
            push @{ $self->{nameservers}{$qname}{$qclass}{ns} }, $rr->nsdname;
        }
    }

    foreach my $ns (@{ $self->{nameservers}{$qname}{$qclass}{ns} }) {

        # Lookup IPv4 addresses for name servers
        my $ipv4 = $self->query_resolver($ns, $qclass, "A");
        foreach my $rr ($ipv4->answer) {
            if ($rr->type eq "A") {
                push @{ $self->{nameservers}{$qname}{$qclass}{ipv4} },
                  $rr->address;
            }
        }

        # Lookup IPv6 addresses for name servers
        my $ipv6 = $self->query_resolver($ns, $qclass, "AAAA");
        foreach my $rr ($ipv6->answer) {
            if ($rr->type eq "AAAA") {
                push @{ $self->{nameservers}{$qname}{$qclass}{ipv6} },
                  $rr->address;
            }
        }
    }
}

######################################################################

sub find_parent {
    my $self   = shift;
    my $qname  = shift;
    my $qclass = shift;

    unless ($self->{parent}{$qname}{$qclass}) {
        $self->{parent}{$qname}{$qclass} =
          $self->_find_parent_helper($qname, $qclass);
    }

    return $self->{parent}{$qname}{$qclass};
}

sub _find_parent_helper {
    my $self   = shift;
    my $qname  = shift;
    my $qclass = shift;

    my $try = $self->_find_authority($qname, $qclass);
    my @labels = split(/\./, $try);

    do {
        shift @labels;
        $try = join(".", @labels);

        my $auth = $self->_find_authority($try, $qclass);
        return $auth unless ($try eq $auth);
    } while ($#labels > 0);

    return $try;
}

sub _find_authority {
    my $self   = shift;
    my $qname  = shift;
    my $qclass = shift;

    my $answer = $self->{resolver}->send($qname, "SOA", $qclass);
    foreach my $rr ($answer->authority) {
        return $rr->name if ($rr->type eq "SOA");
    }

    return $qname;
}

######################################################################

sub find_mail_destination {
	my $self   = shift;
	my $domain = shift;

    my $packet;
	my @dest = ();

 	$packet = $self->query_resolver($domain, "MX", "IN");
	if ($packet->header->ancount > 0) {
		foreach my $rr ($packet->answer) {
			if ($rr->type eq "MX") {
	            push @dest, $rr->exchange;
	        }	        
		}
		goto DONE if (scalar @dest);
	}

	$packet = $self->query_resolver($domain, "A", "IN");
	if ($packet->header->ancount > 0) {
		foreach my $rr ($packet->answer) {
			if ($rr->type eq "A") {
				push @dest, $domain;
				goto DONE;
	        }	        
		}
	}

 	$packet = $self->query_resolver($domain, "AAAA", "IN");
	if ($packet->header->ancount > 0) {
		foreach my $rr ($packet->answer) {
			if ($rr->type eq "AAAA") {
				push @dest, $domain;
				goto DONE;
	        }	        
		}
	}
	
DONE:
	return @dest;
}


######################################################################

1;

__END__
