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

package DNSCheck::Lookup::Resolver;

require 5.008;
use warnings;
use strict;

our $SVN_VERSION = '$Revision$';

use YAML;
use Net::IP;

# In order to be able to know for sure where certain information comes from,
# and/or modify parts of resolver chains, we need to do our own recursive
# lookups rather than rely on an external caching recursive resolver. This
# module is supposed to do recursive lookups. It seems to work, but was
# written by someone who is not a DNS expert, so comments on the module logic
# is very welcome.
sub new {
    my $class  = shift;
    my $parent = shift;
    my $self   = {};

    bless $self, $class;

    $self->{parent} = $parent;

    my $config = $self->config->get("dns");
    $self->{debug} = $parent->config->get("debug");
    $self->{debug} -= 1 if $self->{debug};

    $self->{cache}   = $parent->config->get('root_zone_data');
    $self->{current} = '';

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

    $self->{ipv6} = $parent->config->get("net")->{ipv6};
    $self->{ipv4} = $parent->config->get("net")->{ipv4};

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

sub recursion {
    my $self = shift;

    return $self->resolver->recurse(@_);
}

sub cdflag {
    my $self = shift;

    return $self->resolver->cdflag(@_);
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

    return $self;
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

# Return a made-up packet with information for a name
sub fake_packet {
    my $self = shift;
    my $zone = shift;
    my $name = shift;
    my $type = shift;

    $name = $self->canonicalize_name($name);

    my @ns  = $self->faked_zone($zone);
    my @ips = keys %{ $self->cache->{ips}{$name} };
    my $version;

    if ($type eq 'A') {
        $version = 4;
    } elsif ($type eq 'AAAA') {
        $version = 6;
    } else {
        return;    # Can't or won't fake that
    }

    @ips = grep { Net::IP->new($_)->version == $version } @ips;

    my $p = Net::DNS::Packet->new;

    $p->unique_push('answer', Net::DNS::RR->new("$name 4711 IN $type $_"))
      for @ips;

    for my $ns (@ns) {
        $p->unique_push('authority', Net::DNS::RR->new("$zone 4711 IN NS $ns"));
        for my $ip (
            keys %{ $self->cache->{ips}{ $self->canonicalize_name($ns) } })
        {
            my $t = (Net::IP->new($ip)->version == 4) ? 'A' : 'AAAA';
            $p->unique_push('additional',
                Net::DNS::RR->new("$ns 4711 IN $t $ip"));
        }
    }

    $p->header->aa(1);

    return $p;
}

# Add stuff to our cache.
#
# We cache known nameserver lists for names, and IP addresses for names.
sub remember {
    my ($self, $p) = @_;

    return unless defined($p);

    foreach my $rr ($p->answer, $p->additional, $p->authority) {
        my $n = $self->canonicalize_name($rr->name);
        if ($rr->type eq 'A' or $rr->type eq 'AAAA') {
            $self->{cache}{ips}{$n}{ Net::IP->new($rr->address)->ip } = 1
              unless $self->{fake}{ips}{$n};
        }
        if ($rr->type eq 'NS') {
            $self->{cache}{ns}{$n}{ $self->canonicalize_name($rr->nsdname) } = 1
              unless $self->{fake}{ns}{$n};
        }
    }

    return $self;
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
# initialize on object creation.
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
        my @candidates =
          $self->simple_names_to_ips(keys %{ $self->{cache}{ns}{$name} })
          if $self->{cache}{ns}{$name};
        return @candidates if @candidates;

        if ($name eq '.') {
            die "Root zone cache missing.";
        }

        $name = $self->strip_label($name);
    }
}

sub simple_names_to_ips {
    my $self = shift;
    my @names = map { $self->canonicalize_name($_) } @_;
    my @ips;

    foreach my $n (@names) {
        if ($self->cache->{ips}{$n}) {
            push @ips, keys %{ $self->cache->{ips}{$n} };
        }
    }

    return @ips;
}

sub names_to_ips {
    my $self = shift;
    my @names = map { $self->canonicalize_name($_) } @_;
    my @ips;

    foreach my $n (@names) {
        if ($self->cache->{ips}{$n}) {
            push @ips, keys %{ $self->cache->{ips}{$n} };
        } else {
            next if $self->{poison}{$n};
            $self->{poison}{$n} = 1;    # Block lookups of this name
            my $p = $self->recurse($n, 'A');
            $self->remember($p);

            if ($self->cache->{ips}{$n}) {
                push @ips, keys %{ $self->cache->{ips}{$n} };
                $self->{poison}{$n} = 0;    # Allow lookups of name
            }
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

    print STDERR "get: $name $type $class @ns " . (caller(1))[3] . "\n"
      if $self->{debug};

    @ns = map { $_->ip } grep {
             ($_->version == 4 and $self->{ipv4})
          or ($_->version == 6 and $self->{ipv6})
      } map {
        Net::IP->new($_)
      } @ns;

    return unless @ns;

    my @ns_old = $self->{resolver}->nameservers;
    $self->{resolver}->nameservers(@ns) if @ns;

    my $p = $self->{resolver}->send($name, $class, $type);
    print STDERR "get: " . $p->string . "\n"
      if (defined($p) and $self->{debug} and $self->{debug} > 1);
    $self->remember($p) if defined($p);

    $self->{resolver}->nameservers(@ns_old);
    return $p;
}

# Recursively look up stuff.
#
# Resolution procedure of a name
# ==============================
#
# 1. Get ns names for the highest level we know of (root, probably).
#
# 2. Do name-to-ip for names. Discard names we can't translate.
#
# 3. Push IPs on stack of servers to ask, unless they've already been there.
#
# 4. Pop IP from stack. Send question to it. Remember we asked it.
#    If the stack is empty, return undef.
#
# 5. If we get a response, clear the stack.
#
# 6. If the reply is authoritative, return it.
#    If it is not, but contains records in Authority section, get names from
#    those records and go to 2, unless the records point to a name higher in
#    the chain, in which case we terminate and return undef.

sub recurse {
    my ($self, $name, $type, $class, $cnames) = @_;
    $type   ||= 'NS';
    $class  ||= 'IN';
    $cnames ||= {};

    print STDERR "recurse: $name $type $class\n" if $self->{debug};

    # See if it should be faked
    if (($type eq 'A' or $type eq 'AAAA')
        and $self->{fake}{ips}{ $self->canonicalize_name($name) })
    {
        return $self->fake_packet(undef, $name, $type);
    }

    my @stack = $self->highest_known_ns($name);
    my %seen;
    my $candidate;

    my $level = -1;

    while (@stack) {
        my $ns = pop(@stack);
        print STDERR "Popped $ns (stack is "
          . scalar(@stack)
          . " entries deep).\n"
          if $self->{debug};
        $seen{$ns} = 1;
        my $p = $self->get($name, $type, $class, $ns);
        if (!defined($p)) {
            print STDERR "No response packet.\n" if $self->{debug};
            next;
        } elsif ($p->header->aa) {
            print STDERR "Authoritative response.\n" if $self->{debug};

            if (    $p->header->rcode ne 'NOERROR'
                and $p->header->rcode ne 'NXDOMAIN')
            {
                print STDERR "...but it's not good. Saving as candidate.\n"
                  if $self->{debug};
                $candidate = $p;
                next;
            }

            if (    $type ne 'CNAME'
                and $p->header->ancount > 0
                and grep { $_->type eq 'CNAME' } $p->answer)
            {
                print STDERR "Resolving CNAME.\n" if $self->{debug};
                my $cnamerr = (grep { $_->type eq 'CNAME' } $p->answer)[0];
                return $p if $cnames->{ $cnamerr->cname };    # Break loops
                $cnames->{ $cnamerr->cname } = 1;
                my $tmp =
                  $self->recurse($cnamerr->cname, $type, $class, $cnames);
                if ($tmp) {
                    print STDERR "recurse: Adding CNAME to response packet.\n"
                      if $self->{debug};
                    $tmp->unique_push(answer => $cnamerr)
                      unless (keys %$cnames) > 1;
                    return $tmp;
                } else {
                    return $p;
                }
            }

            return $p;
        } elsif ($p->header->rcode ne 'NOERROR') {
            print STDERR "Response code " . $p->header->rcode . "\n"
              if $self->{debug};
            $candidate = $p unless $candidate;
            next;
        } elsif (
            $p->header->ancount > 0 and grep {
                $_->type eq 'CNAME'
            } $p->answer
          )
        {
            print STDERR "Resolving non-auth CNAME.\n" if $self->{debug};
            my $cnamerr = (grep { $_->type eq 'CNAME' } $p->answer)[0];
            return $p if $cnames->{ $cnamerr->cname };    # Break loops
            $cnames->{ $cnamerr->cname } = 1;
            my $tmp = $self->recurse($cnamerr->cname, $type, $class, $cnames);
            if ($tmp) {
                print STDERR "recurse: Adding CNAME to response packet.\n"
                  if $self->{debug};
                $tmp->unique_push(answer => $cnamerr)
                  unless (keys %$cnames) > 1;
                return $tmp;
            } else {
                return $p;
            }
        } elsif ($p->header->nscount > 0) {
            print STDERR "Got "
              . scalar($p->authority)
              . " authority records. Reloading stack.\n"
              if $self->{debug};
            @stack = ();
            my $zname = ($p->authority)[0]->name;
            my $m = $self->matching_labels($name, $zname);

            if ($m < $level) {
                next;    # Resolving chain redirecting up
            }

            $level = $m;

            if (my @fns = $self->faked_zone($zname)) {
                push @stack, $self->simple_names_to_ips(@fns);
            } else {
                $self->remember($p);
                push @stack, grep { !$seen{$_} } $self->names_to_ips(
                    map { $_->nsdname }
                      grep { $_->type eq 'NS' } $p->authority
                );
            }
            next;
        } else {
            print STDERR "Fell through: " . $p->print if $self->{debug};
        }
    }

    print STDERR "Ran out of servers.\n" if $self->{debug};

    # Ran out of servers before we got a good reply, return what we've got
    if ($candidate) {
        return $candidate;
    } else {
        return;
    }
}

sub matching_labels {
    my $self = shift;
    my ($n1, $n2) = @_;

    my @n1 = reverse split /\./, $n1;
    my @n2 = reverse split /\./, $n2;
    my $count = 0;

    while (@n1 and @n2) {
        my $i = shift @n1;
        my $j = shift @n2;

        if ($i eq $j) {
            $count += 1;
        } else {
            last;
        }
    }

    return $count;
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
