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

use DNSCheck::Context;
use DNSCheck::Config;
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
use DNSCheck::Lookup::DNS;
use DNSCheck::Lookup::ASN;
use DNSCheck::Logger;

our $VERSION = "0.90_01";

######################################################################

sub new {
    my $proto = shift;
    my $class = ref($proto) || $proto;
    my $self  = {};
    bless $self, $class;

    my $config_args = shift;
    my $config      = DNSCheck::Config->new(%{$config_args});
    $self->{config} = $config;

    # create DNSCheck context
    $self->{context} = new DNSCheck::Context($self);

    return $self;
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
    
    unless (defined($self->{logger})) {
        $self->{logger} = DNSCheck::Logger->new($self)
    }

    return $self->{logger};
}

sub dns {
    my $self = shift;
    
    unless (defined($self->{dns})) {
            $self->{dns} = DNSCheck::Lookup::DNS->new($self);
    }
    
    return $self->{dns};
}

sub asn {
    my $self = shift;
    
    unless (defined($self->{asn})) {
        $self->{asn} = DNSCheck::Lookup::ASN->new($self);
    }
    
    return $self->{asn};
}

sub config {
    my $self = shift;
    return $self->{config};
}

# Hopefully we will be able to remove this one soon.
sub context {
    my $self = shift;
    return $self->{context};
}

######################################################################

sub zone {
    my $self = shift;
    DNSCheck::Test::Zone->test($self, @_);
}

sub host {
    my $self = shift;
    DNSCheck::Test::Host->test($self, @_);
}

sub address {
    my $self = shift;
    DNSCheck::Test::Address->test($self, @_);
}

sub soa {
    my $self = shift;
    DNSCheck::Test::SOA->test($self, @_);
}

sub connectivity {
    my $self = shift;
    DNSCheck::Test::Connectivity->test($self, @_);
}

sub consistency {
    my $self = shift;
    DNSCheck::Test::Consistency->test($self, @_);
}

sub delegation {
    my $self = shift;
    DNSCheck::Test::Delegation->test($self, @_);
}

sub nameserver {
    my $self = shift;
    DNSCheck::Test::Nameserver->test($self, @_);
}

sub dnssec {
    my $self = shift;
    DNSCheck::Test::DNSSEC->test($self, @_);
}

sub mail {
    my $self = shift;
    DNSCheck::Test::Mail->test($self, @_);
}

sub smtp {
    my $self = shift;
    DNSCheck::Test::SMTP->test($self, @_);
}

######################################################################

1;

__END__


=head1 NAME

DNSCheck - DNS Check Tools

=head1 DESCRIPTION

...

=head1 METHODS

new(I<config>);

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
	$check->logger->print;

=cut
