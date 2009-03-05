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

package DNSCheck::Lookup::ASN;

require 5.008;
use warnings;
use strict;

our $SVN_VERSION = '$Revision$';

use Data::Dumper;
use Net::DNS;
use Net::IP;

######################################################################

our $asn_domain = "asn.routeviews.org.";
our $asn_magic  = 4294967295;

######################################################################

sub new {
    my $proto = shift;
    my $class = ref($proto) || $proto;
    my $self  = {};
    bless $self, $class;

    $self->{parent} = shift;

    # hash of ASN indexed by IP
    $self->{asn} = ();

    return $self;
}

sub parent {
    my $self = shift;

    return $self->{parent};
}

sub flush {
    my $self = shift;

    $self->{asn} = ();
}

sub lookup {
    my $self = shift;
    my $ip   = shift;

    $self->parent->logger->auto("ASN:LOOKUP", $ip);

    my $nip = Net::IP->new($ip);

    if (!$nip) {
        $self->parent->logger->auto("ASN:INVALID_ADDRESS", $ip);
        return undef;
    } 
    # Uncomment this when we want to include v6 servers in the check
    # elsif ($nip->version == 6) {
    #     return $self->lookup6($ip);
    # }

    unless ($self->{asn}{$ip}) {
        $self->{asn}{$ip} = $self->_asn_helper($ip);
    }

    my $asn = $self->{asn}{$ip};

    if ($asn) {
        if (scalar @{$asn} > 0) {
            $self->parent->logger->auto("ASN:ANNOUNCE_BY", $ip,
                join(",", @{$asn}));
        } else {
            $self->parent->logger->auto("ASN:NOT_ANNOUNCE", $ip);
        }
    } else {
        $self->parent->logger->auto("ASN:LOOKUP_ERROR", $ip);
    }

    return $asn;
}

sub _asn_helper {
    my $self = shift;
    my $ip   = shift;

    my @asn_list = ();

    my $qname =
      sprintf("%s.%s", join(".", reverse(split(/\./, $ip))), $asn_domain);

    my $packet = $self->parent->dns->query_resolver($qname, "IN", "TXT");

    unless ($packet && $packet->header->ancount) {
        ## lookup failure
        return ["Lookup Failure"];
    }

    foreach my $rr ($packet->answer) {
        if ($rr->rdatastr =~ /^\"(\d+)\"/) {
            if ($1 eq $asn_magic) {
                ## IP address not announced
                goto DONE;
            } else {
                ## IP address announced
                push @asn_list, $1;
            }
        }
    }

  DONE:
    return \@asn_list;
}

sub lookup6 {
    my $self   = shift;
    my $raw_ip = shift;

    unless ($self->{asn}{$raw_ip}) {
        $self->{asn}{$raw_ip} = $self->_lookup6($raw_ip);
    }

    return $self->{asn}{$raw_ip};
}

sub _lookup6 {
    my $self   = shift;
    my $raw_ip = shift;

    my $ip = Net::IP->new($raw_ip);
    return unless defined($ip);

    my $rev = $ip->reverse_ip;
    $rev =~ s/ip6\.arpa/origin6.asn.cymru.com/;
    my $packet = $self->parent->dns->query_resolver($rev, 'IN', 'TXT');
    return unless (defined($packet) and $packet->header->ancount > 0);

    my @asn;
    foreach my $rr ($packet->answer) {
        next unless $rr->type eq 'TXT';
        foreach my $txt ($rr->char_str_list) {
            if ($txt =~ /^(\d+)\s*\|/) {
                push @asn, $1;
            }
        }
    }

    return \@asn;
}

1;

__END__


=head1 NAME

DNSCheck::Lookup::ASN - AS Number Lookup

=head1 DESCRIPTION

Helper functions for looking up AS (Autonomous System) numbers using 
B<asn.cymru.com>.

=head1 METHODS

new(I<logger>, I<dns>);

flush();

my $n = $asn->lookup(I<address>);

=head1 EXAMPLES

    use DNSCheck;

    my $asn    = DNSCheck->new->asn;

    $asn->lookup("64.233.183.99");

=head1 SEE ALSO

L<DNSCheck>

=cut
