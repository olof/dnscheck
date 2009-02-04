#!/usr/bin/perl
#
# $Id: ASN.pm 590 2008-12-12 15:27:07Z calle $
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

package DNSCheck::Lookup::Resolver;

require 5.008;
use warnings;
use strict;

use YAML;
use Net::IP;

# In order to be able to know for sure where certain information comes from,
# and/or modify parts of resolver chains, we need to do our own recursive
# lookups rather than rely on an external caching recursive resolver. This
# module is supposed to do recursive lookups. It seems to work, but was
# written by someone who is not a DNS expert, so comments on the module logic
# is very welcome.
sub new {
    my $proto  = shift;
    my $parent = shift;
    my $class  = ref($proto) || $proto;
    my $self   = {};

    bless $self, $proto;

    $self->{parent} = $parent;

    my $config = $self->config->get("dns");
    $self->{debug} = $parent->config->get("debug");

    $self->{cache} = $parent->config->get('root_zone_data');

    $self->{resolver} = Net::DNS::Resolver->new(

   # RFC3330 reserved address. As close to guaranteed *not* to have a nameserver
   # on it as we're likely to get (the module does not accept an empty list).
        nameservers => ['192.0.2.1'],
    );
    $self->{resolver}->persistent_tcp(0);
    $self->{resolver}->cdflag(1);
    $self->{resolver}->recurse(0);
    $self->{resolver}->dnssec(0);
    $self->{resolver}->debug(1) if ($self->{debug} and $self->{debug} > 1);
    $self->{resolver}->udp_timeout($config->{udp_timeout});
    $self->{resolver}->tcp_timeout($config->{tcp_timeout});
    $self->{resolver}->retry($config->{retry});
    $self->{resolver}->retrans($config->{retrans});

    return $self;
}

# Standard utility methods
sub resolver {
    return $_[0]->{resolver};
}

sub parent {
    return $_[0]->{parent};
}

sub cache {
    return $_[0]->{cache};
}

sub config {
    return $_[0]->parent->config;
}

sub logger {
    return $_[0]->parent->logger;
}

# Interface methods to underlying Net::DNS::Resolver object

sub errorstring {
    my $self = shift;

    return $self->resolver->errorstring(@_);
}

sub dnssec {
    my $self = shift;

    return $self->resolver->dnssec(@_);
}

# Methods to support undelegated testing

sub add_fake_glue {
    my $self   = shift;
    my $zone   = shift;
    my $nsname = shift;
    my $nsip   = shift;

    $nsname = $self->canonicalize_name($nsname);
    $zone   = $self->canonicalize_name($zone);

    $self->cache->{ns}{$zone}{$nsname}  = 1;
    $self->cache->{ips}{$nsname}{$nsip} = 1;
    $self->{fake}{ns}{$zone}            = 1;
    $self->{fake}{ips}{$nsname}         = 1;
}

# Return a list of zones with fake glue
sub faked_zones {
    my $self = shift;

    return map { s/\.$//; $_ } keys %{ $self->{fake}{ns} };
}

# Return a list of NS names for a zone with fake glue
sub faked_zone {
    my $self = shift;
    my $name = shift;

    $name = $self->canonicalize_name($name);

    if ($self->{fake}{ns}{$name}) {
        return map { s/\.$//; $_ } keys %{ $self->cache->{ns}{$name} };
    } else {
        return;
    }
}

# Add stuff to our cache.
#
# We cache known nameserver lists for names, and IP addresses for names.
sub remember {
    my ($self, $p, $name, $type, $class) = @_;

    return unless defined($p);

    foreach my $rr ($p->answer, $p->additional, $p->authority) {
        my $n = $self->canonicalize_name($rr->name);
        if ($rr->type eq 'A' or $rr->type eq 'AAAA') {
            $self->{cache}{ips}{$n}{ $rr->address } = 1
              unless $self->{fake}{ips}{$n};
        }
        if ($rr->type eq 'NS') {
            $self->{cache}{ns}{$n}{ $self->canonicalize_name($rr->nsdname) } = 1
              unless $self->{fake}{ns}{$n};
        }
    }
}

# Class method to generate data with which to preload the cache.
sub get_preload_data {
    my $self = shift;
    my %cache;

    my $res = Net::DNS::Resolver->new;
    my $z = $res->send('.', 'IN', 'NS');

    if (!defined($z) or $z->header->ancount == 0) {
        die "Failed to get root zone data";
    }

    foreach my $rr ($z->answer) {
        next unless $rr->type eq 'NS';

        $cache{ns}{'.'}{ $self->canonicalize_name($rr->nsdname) } = 1;
    }

    foreach my $nsname (keys %{ $cache{ns}{'.'} }) {
        $nsname = $self->canonicalize_name($nsname);

        my $a = $res->send($nsname, 'IN', 'A');
        next if (!defined($a) or $a->header->ancount == 0);
        foreach my $rr ($a->answer) {
            next unless $rr->type eq 'A';

            $cache{ips}{$nsname}{ $rr->address } = 1;
        }

        my $aaaa = $res->send($nsname, 'IN', 'AAAA');
        next if (!defined($aaaa) or $aaaa->header->ancount == 0);
        foreach my $rr ($aaaa->answer) {
            next unless $rr->type eq 'AAAA';

            $cache{ips}{$nsname}{ $rr->address } = 1;
        }
    }

    return \%cache;
}

# Reformat a name into a standardized form, for ease of comparison
sub canonicalize_name {
    my $self = shift;
    my $name = shift;

    if (my $i = Net::IP->new($name)) {
        $name = $i->reverse_ip;
    }

    $name = lc($name);

    $name .= '.' unless substr($name, -1) eq '.';

    return $name;
}

# Strip the leftmost label off a DNS name. If there are no labels left after
# removing one, returns a single period for the root level.
sub strip_label {
    my $self = shift;
    my $name = shift;

    my @labels = split /\./, $name;
    shift @labels;

    if (@labels) {
        return $self->canonicalize_name(join '.', @labels);
    } else {
        return '.';
    }
}

# Take a name, and return the nameserver names for the highest parent level we
# have in cache. Which, at worst, will be the root zone, the data for which we
# have hardcoded into the module.
sub highest_known_ns {
    my $self = shift;
    my $name = shift;

    $name = $self->canonicalize_name($name);

    # If there are more than one zone with fake glue, and one is a parent of
    # another, choose the one with the most labels in it.
    my $faked = (
        sort { $b =~ y/././ <=> $a =~ y/././ }
          grep { $name =~ /$_$/ } $self->faked_zones
    )[0];

    if ($faked) {
        return keys %{ $self->cache->{ns}{$faked} };
    }

    while (1) {
        return keys %{ $self->{cache}{ns}{$name} } if $self->{cache}{ns}{$name};
        if ($name eq '.') {
            die "Root zone cache missing.";
        }

        $name = $self->strip_label($name);
    }
}

sub simple_names_to_ips {
    my $self  = shift;
    my @names = @_;
    my @ips;

    foreach my $n (@names) {
        if ($self->cache->{ips}{$n}) {
            push @ips, keys %{ $self->cache->{ips}{$n} };
        }
    }

    return @ips;
}

# Send a query to a specified set of nameservers and return the result.
sub get {
    my $self  = shift;
    my $name  = shift;
    my $type  = shift || 'NS';
    my $class = shift || 'IN';
    my @ns    = @_;

    print STDERR "get: $name $type $class @ns ".(caller(1))[3]."\n" if $self->{debug};

    my @ns_old = $self->{resolver}->nameservers;
    $self->{resolver}->nameservers(@ns) if @ns;

    my $p = $self->{resolver}->send($name, $class, $type);
    print STDERR "get: " . $p->string . "\n"
      if (defined($p) and $self->{debug} and $self->{debug} > 1);
    $self->remember($p, $name, $type, $class) if defined($p);

    $self->{resolver}->nameservers(@ns_old);
    return $p;
}

# Recursively look up stuff.
sub recurse {
    my $self  = shift;
    my $name  = shift;
    my $type  = shift || 'NS';
    my $class = shift || 'IN';

    my %tried;

    $name = $self->canonicalize_name($name);

    printf(STDERR "recurse: %s %s %s (%s)\n", $name, $type, $class, (caller(1))[3] )
        if $self->{debug};

    my $p =
      $self->get($name, $type, $class,
        $self->simple_names_to_ips($self->highest_known_ns($name)));

    return unless defined($p);

    my $h = $p->header;

    while (1) {

        if ($h->aa) {    # An authoritative answer
            print STDERR "recurse: authoritative\n" if $self->{debug};
            return $p;
        } elsif ($h->rcode ne 'NOERROR') {
            print STDERR "recurse: " . $h->rcode . "\n" if $self->{debug};
            return $p;
        } elsif ($h->nscount > 0) {    # Authority records
            my @ns;
            foreach my $rr ($p->authority) {
                if ($rr->type eq 'NS') {
                    my $n = $self->canonicalize_name($rr->nsdname);
                    next if $self->{poison}{$n};
                    if (my $ip = $self->{cache}{ips}{$n}) {
                        push @ns, keys %$ip;
                    } else {
                        $self->recurse($n, 'A');
                        if (my $ip = $self->{cache}{ips}{$n}) {
                            push @ns, keys %$ip;
                        } else {
                            $self->{poison}{$n} = 1;
                        }
                    }
                } elsif ($rr->type eq 'SOA') {
                    return $p;
                }
            }
            my $fingerprint = join '|', sort @ns;
            if ($tried{$fingerprint}) {

                print STDERR "recurse: looping\n" if $self->{debug};
                return;
            } else {
                $tried{$fingerprint} = 1;
            }

            $p = $self->get($name, $type, $class, @ns);
            unless (defined($p)) {
                print STDERR "recurse: failed to follow\n" if $self->{debug};
                return;
            }
            $h = $p->header;
        } else {

            # Do something different here?
            print STDERR "recurse: wtf\n" if $self->{debug};
            return $p;
        }
    }
}

=head1 NAME

DNSCheck::Lookup::Resolver - a recursive DNS resolver for DNSCheck

=head1 DESCRIPTION

This module does recursive lookups, and is heavily used by L<DNSCheck::Lookup::DNS>. 

=head1 METHODS

=over

=item ->new($parent)

Creates and configures a new resolver object. The parent object should be a
L<DNSCheck> object, and it will be used to find DNS resolver configuration
information.

=item ->get($name, $type, $class, @nameservers)

Send a DNS query to specified servers.

=item ->recurse($name, $type, [$class])

Do a recursive query. If the class is not specified, it defaults to IN.

=back

=cut
