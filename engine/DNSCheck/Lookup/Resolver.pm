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

use base 'Net::DNS::Resolver';

use YAML;
use Net::IP;

sub new {
    my $proto = shift;
    my $class = ref($proto) || $proto;
    my $self  = {};
    bless $self, $proto;

    $self->{cache} = Load(join('', <DATA>));
    $self->{resolver} = Net::DNS::Resolver->new;

    return $self;
}

sub remember {
    my ($self, $p, $name, $type, $class) = @_;

    return unless defined($p);

    foreach my $rr ($p->answer, $p->additional, $p->authority) {
        my $n = $self->canonicalize_name($rr->name);
        if ($rr->type eq 'A' or $rr->type eq 'AAAA') {
            push @{ $self->{cache}{ips}{$n} }, $rr->address;
        }
        if ($rr->type eq 'NS') {
            push @{ $self->{cache}{ns}{$n} },
              $self->canonicalize_name($rr->nsdname);
        }
    }
}

sub canonicalize_name {
    my $self = shift;
    my $name = shift;

    $name = lc($name);

    if (my $i = Net::IP->new($name)) {
        $name = $i->reverse_ip;
    }

    $name .= '.' unless substr($name, -1) eq '.';

    return $name;
}

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

sub highest_known_ns {
    my $self = shift;
    my $name = shift;

    while ($name ne '.') {
        return @{ $self->{cache}{ns}{$name} } if $self->{cache}{ns}{$name};
        $name = $self->strip_label($name);
    }

    return grep { $_ }
      map { $self->{cache}{ips}{$_} and @{ $self->{cache}{ips}{$_} } }
      @{ $self->{cache}{ns}{'.'} };
}

sub get {
    my $self  = shift;
    my $name  = shift;
    my $type  = shift || 'NS';
    my $class = shift || 'IN';
    my @ns    = @_;

    my @ns_old = $self->{resolver}->nameservers;
    $self->{resolver}->nameservers(@ns) if @ns;

    my $p = $self->{resolver}->send($name, $class, $type);
    $self->remember($p, $name, $type, $class) if defined($p);

    $self->{resolver}->nameservers(@ns_old);
    return $p;
}

sub recurse {
    my $self = shift;
    my $name = shift;
    my $type = shift || 'NS';

    my $done = undef;

    $name = $self->canonicalize_name($name);

    my $p = $self->get($name, $type, 'IN', $self->highest_known_ns($name));
    my $h = $p->header;

    die(
        sprintf(
            "%s for %s record for %s",
            $self->{res}->errorstring,
            $type, $name
        )
    ) unless defined($p);
  TOP:

    until ($done) {

        if ($h->rcode ne 'NOERROR') {
            return $p;
        } elsif ($h->ancount > 0) {    # An actual answer
            $done = 1;
        } elsif ($h->nscount > 0) {    # Authority records
            my @ns;
            foreach my $rr ($p->authority) {
                if ($rr->type eq 'NS') {
                    my $n = $self->canonicalize_name($rr->nsdname);
                    if (my $ip = $self->{cache}{ips}{$n}) {
                        push @ns, @$ip;
                    } else {
                        $self->recurse($n, 'A');
                        redo TOP;
                    }
                } elsif ($rr->type eq 'SOA') {
                    $done = 1;
                }
            }
            $p = $self->get($name, $type, 'IN', @ns);
            die(
                sprintf(
                    "%s for %s record for %s\n",
                    $self->{resolver}->errorstring,
                    $type, $name
                )
            ) unless defined($p);
            $h = $p->header;
        }
    }

    return $p;
}

__DATA__
---
ips:
  a.root-servers.net.:
    - 198.41.0.4
    - 2001:503:ba3e:0:0:0:2:30
  b.root-servers.net.:
    - 192.228.79.201
  c.root-servers.net.:
    - 192.33.4.12
  d.root-servers.net.:
    - 128.8.10.90
  e.root-servers.net.:
    - 192.203.230.10
  f.root-servers.net.:
    - 192.5.5.241
    - 2001:500:2f:0:0:0:0:f
  g.root-servers.net.:
    - 192.112.36.4
  h.root-servers.net.:
    - 128.63.2.53
    - 2001:500:1:0:0:0:803f:235
  i.root-servers.net.:
    - 192.36.148.17
  j.root-servers.net.:
    - 192.58.128.30
    - 2001:503:c27:0:0:0:2:30
ns:
  .:
    - i.root-servers.net.
    - j.root-servers.net.
    - k.root-servers.net.
    - l.root-servers.net.
    - m.root-servers.net.
    - a.root-servers.net.
    - b.root-servers.net.
    - c.root-servers.net.
    - d.root-servers.net.
    - e.root-servers.net.
    - f.root-servers.net.
    - g.root-servers.net.
    - h.root-servers.net.
