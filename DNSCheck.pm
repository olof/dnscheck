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

package DNSCheck;

require 5.8.0;
use warnings;
use strict;
use Data::Dumper;

use DNSCheck::Context;
use DNSCheck::Test::Host;
use DNSCheck::Test::Address;
use DNSCheck::Test::SOA;
use DNSCheck::Test::Zone;
use DNSCheck::Test::Connectivity;
use DNSCheck::Test::Consistency;
use DNSCheck::Test::Delegation;
use DNSCheck::Test::Nameserver;
use DNSCheck::Test::DNSSEC;
use DNSCheck::Test::Mail;
use DNSCheck::Test::SMTP;

our $VERSION = "0.65";

our $default = {
    dns => {
        debug       => 0,
        ipv4        => 1,
        ipv6        => 1,
        class       => "IN",
        udp_timeout => 5,
        tcp_timeout => 5,
        retry       => 3,
        retrans     => 2,
    },

    smtp => {
        enable   => 1,
        hostname => `hostname`,
        timeout  => 20,
    },

    logging => {
        interactive => 0,
        locale      => undef,
    },

    policy => {
        params => {
            'SOA:EXPIRE_VS_REFRESH' => 7,
            'SOA:MAX_MINIMUM'       => 86400,
            'SOA:MIN_EXPIRE'        => 604800,
            'SOA:MIN_MINIMUM'       => 300,
            'SOA:MIN_REFRESH'       => 1440,
            'SOA:MIN_RETRY'         => 3600,
            'SOA:MIN_TTL'           => 3600,
        }
    }
};

######################################################################

sub new {
    my $proto = shift;
    my $class = ref($proto) || $proto;
    my $self  = {};

    # config, policy, locale are HASH references
    my $config = shift;

    # apply default DNS configuration
    foreach my $p (keys %{ $default->{dns} }) {
        $config->{dns}->{$p} = $default->{dns}->{$p}
          unless $config->{dns}->{$p};
    }

    # apply default SMTP configuration
    foreach my $p (keys %{ $default->{smtp} }) {
        $config->{smtp}->{$p} = $default->{smtp}->{$p}
          unless $config->{smtp}->{$p};
    }

    # strip any newline from SMTP hostname
    chomp $config->{smtp}->{hostname};

    # apply default LOGGING configuration
    foreach my $p (keys %{ $default->{logging} }) {
        $config->{logging}->{$p} = $default->{logging}->{$p}
          unless $config->{logging}->{$p};
    }

    # apply default POLICY
    foreach my $p (keys %{ $default->{policy}->{params} }) {
        $config->{policy}->{params}->{$p} = $default->{policy}->{params}->{$p}
          unless $config->{policy}->{params}->{$p};
    }

	# create DNSCheck context
    $self->{context} = new DNSCheck::Context($config);

    bless $self, $class;
}

######################################################################

sub flush {
    my $self = shift;

    $self->{context}->{dns}->flush();

    # should the ASN cache be flushed as well?
    #$self->{context}->{asn}->flush();
}

######################################################################

sub logger {
    my $self = shift;
    return $self->{context}->logger;
}

######################################################################

sub zone {
    my $self = shift;
    DNSCheck::Test::Zone::test($self->{context}, @_);
}

sub host {
    my $self = shift;
    DNSCheck::Test::Host::test($self->{context}, @_);
}

sub address {
    my $self = shift;
    DNSCheck::Test::Address::test($self->{context}, @_);
}

sub soa {
    my $self = shift;
    DNSCheck::Test::SOA::test($self->{context}, @_);
}

sub connectivity {
    my $self = shift;
    DNSCheck::Test::Connectivity::test($self->{context}, @_);
}

sub consistency {
    my $self = shift;
    DNSCheck::Test::Consistency::test($self->{context}, @_);
}

sub delegation {
    my $self = shift;
    DNSCheck::Test::Delegation::test($self->{context}, @_);
}

sub nameserver {
    my $self = shift;
    DNSCheck::Test::Nameserver::test($self->{context}, @_);
}

sub dnssec {
    my $self = shift;
    DNSCheck::Test::DNSSEC::test($self->{context}, @_);
}

sub mail {
    my $self = shift;
    DNSCheck::Test::Mail::test($self->{context}, @_);
}

sub smtp {
    my $self = shift;
    DNSCheck::Test::SMTP::test($self->{context}, @_);
}

1;

__END__


=head1 NAME

DNSCheck - DNS Check Tools

=head1 DESCRIPTION

...

=head1 METHODS

new(I<config>);

$dns->report();

$dns->zone(I<zone>);

$dns->host(I<hostname>);

$dns->address(I<address>);

$dns->soa(I<zone>);

$dns->connectivity(I<zone>);

$dns->consistency(I<zone>);

$dns->delegation(I<zone>);

$dns->nameserver(I<zone>, I<nameserver>));

$dns->dnssec(I<zone>);

$dns->mail(I<emailaddress>);

$dns->smtp(I<mailhost>, I<emailaddress>);

=head1 EXAMPLES

    use DNSCheck;

	my $check = new DNSCheck({ class => "IN" });

	$check->zone("example.com");
	$check->report();

=cut
