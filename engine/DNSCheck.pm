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

use DBI;
use Carp;

use DNSCheck::Context;
use DNSCheck::Config;
use DNSCheck::Test::Common;
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
    if ($config_args->{with_config_object}) {
        $self->{config} = $config_args->{with_config_object};
    } else {
        $self->{config} = DNSCheck::Config->new(%{$config_args});
    }

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
        $self->{logger} = DNSCheck::Logger->new($self);
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

sub dbh {
    my $self = shift;

    unless (defined($self->config->get("dbi"))) {
        return undef;
    }

    unless (defined($self->{"dbh"}) && $self->{"dbh"}->ping) {
        my $conf = $self->config->get("dbi");
        my $dsn  = sprintf("DBI:mysql:database=%s;hostname=%s;port=%s",
            $conf->{"database"}, $conf->{"host"}, $conf->{"port"});
        my $dbh = DBI->connect($dsn, $conf->{"user"}, $conf->{"password"});
        carp "Failed to connect to database: $DBI::errstr" unless defined($dbh);
        $self->{"dbh"} = $dbh;
    }

    return $self->{"dbh"};
}

######################################################################
# Test objects
######################################################################

sub zone {
    my $self = shift;
    unless (defined($self->{test_zone})) {
        $self->{test_zone} = DNSCheck::Test::Zone->new($self);
    }

    return $self->{test_zone};
}

sub host {
    my $self = shift;

    unless (defined($self->{test_host})) {
        $self->{test_host} = DNSCheck::Test::Host->new($self);
    }

    return $self->{test_host};
}

sub address {
    my $self = shift;

    unless (defined($self->{test_address})) {
        $self->{test_address} = DNSCheck::Test::Address->new($self);
    }

    return $self->{test_address};
}

sub soa {
    my $self = shift;

    unless (defined($self->{test_soa})) {
        $self->{test_soa} = DNSCheck::Test::SOA->new($self);
    }

    return $self->{test_soa};
}

sub connectivity {
    my $self = shift;

    unless (defined($self->{test_connectivity})) {
        $self->{test_connectivity} = DNSCheck::Test::Connectivity->new($self);
    }

    return $self->{test_connectivity};
}

sub consistency {
    my $self = shift;

    unless (defined($self->{test_consistency})) {
        $self->{test_consistency} = DNSCheck::Test::Consistency->new($self);
    }

    return $self->{test_consistency};
}

sub delegation {
    my $self = shift;

    unless (defined($self->{test_delegation})) {
        $self->{test_delegation} = DNSCheck::Test::Delegation->new($self);
    }

    return $self->{test_delegation};
}

sub nameserver {
    my $self = shift;

    unless (defined($self->{test_nameserver})) {
        $self->{test_nameserver} = DNSCheck::Test::Nameserver->new($self);
    }

    return $self->{test_nameserver};
}

sub dnssec {
    my $self = shift;

    unless (defined($self->{test_dnssec})) {
        $self->{test_dnssec} = DNSCheck::Test::DNSSEC->new($self);
    }

    return $self->{test_dnssec};
}

sub mail {
    my $self = shift;

    unless (defined($self->{test_mail})) {
        $self->{test_mail} = DNSCheck::Test::Mail->new($self);
    }

    return $self->{test_mail};
}

sub smtp {
    my $self = shift;

    unless (defined($self->{test_smtp})) {
        $self->{test_smtp} = DNSCheck::Test::SMTP->new($self);
    }

    return $self->{test_smtp};
}

######################################################################

1;

__END__


=head1 NAME

DNSCheck - DNS Check Tools

=head1 DESCRIPTION

This module provides the main external interface to the actual tests in the
DNSCheck system.

=head1 METHODS

=over

=item ->new(I<config>);

I<config> is a reference to a hash holding configuration keys. They will be
blindly used to create a L<DNSCheck::Config> object, unless one key is
C<with_config_object>. If there is such a key, its value will be used as the
L<DNSCheck::Config> object. No check to see if it actually I<is> such an
object will be done, so anything that responds to the right methods can be
used.

Providing a pre-created config object can be useful when creating and
discarding a large number of L<DNSCheck> objects, since config object creation
normally stands for the majority of the time it takes to create such an
object. Creating the config object once and then providing it to every
L<DNSCheck> may save considerable time in the long run.

=back

=head1 EXAMPLES

=cut
