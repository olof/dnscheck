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

package DNSCheck::Test::Connectivity;

require 5.008;
use warnings;
use strict;

our $SVN_VERSION = '$Revision$';

use base 'DNSCheck::Test::Common';

######################################################################

sub test {
    my $self = shift;
    my $zone = shift;

    my $parent = $self->parent;
    my $qclass = $self->qclass;
    my $logger = $self->logger;

    return unless $parent->config->should_run;

    $logger->module_stack_push();
    $logger->auto("CONNECTIVITY:BEGIN", $zone);

    my $errors = $self->test_v4($zone) + $self->test_v6($zone);

    $logger->auto("CONNECTIVITY:END", $zone);
    $logger->module_stack_pop();

    return $errors;
}

sub test_v4 {
    my $self = shift;
    my $zone = shift;

    my $parent = $self->parent;
    my $qclass = $self->qclass;
    my $logger = $self->logger;
    my $errors = 0;

    return 0 unless $parent->config->should_run;

    my %as_set;
    my @nameservers = ();

    # Fetch IPv4 nameservers
    if ($parent->config->get("net")->{ipv4}) {
        my $ipv4 = $parent->dns->get_nameservers_ipv4($zone, $qclass);
        push @nameservers, @{$ipv4} if ($ipv4);
    }

    foreach my $address (@nameservers) {
        my $as_lookup = $parent->asn->lookup($address);
        my @as_list   = ();
        @as_list = @{$as_lookup} if $as_lookup;

        foreach my $asn (@as_list) {
            $as_set{$asn} = $asn;
        }

        $logger->auto("CONNECTIVITY:ANNOUNCED_BY_ASN",
            $address, join(",", @as_list));

        # REQUIRE: A name server should not be announced by more than one AS
        # REQUIRE: A name server must be announced
        if (scalar @as_list > 1) {
            $logger->auto("CONNECTIVITY:MULTIPLE_ASN", $address);
        } elsif (scalar @as_list < 1) {
            $errors += $logger->auto("CONNECTIVITY:NOT_ANNOUNCED", $address);
        }
    }

    $logger->auto("CONNECTIVITY:ASN_LIST", join(",", keys(%as_set)));

    # REQUIRE: Domain name servers should live in more than one AS
    my $as_count = scalar keys %as_set;
    if ($as_count <= 1) {
        $errors += $logger->auto("CONNECTIVITY:TOO_FEW_ASN", $as_count);
    } else {
        $logger->auto("CONNECTIVITY:ASN_COUNT_OK", $as_count);
    }

  DONE:

    return $errors;
}

sub test_v6 {
    my $self = shift;
    my $zone = shift;

    my $parent = $self->parent;
    my $qclass = $self->qclass;
    my $logger = $self->logger;
    my $errors = 0;

    return 0 unless $parent->config->should_run;

    my %as_set;
    my @nameservers = ();

    # Fetch IPv6 nameservers.
    if ($parent->config->get("net")->{ipv6}) {
        my $ipv6 = $parent->dns->get_nameservers_ipv6($zone, $qclass);
        push @nameservers, @{$ipv6} if ($ipv6);
    }

    foreach my $address (@nameservers) {
        my $as_lookup = $parent->asn->lookup($address);
        my @as_list   = ();
        @as_list = @{$as_lookup} if $as_lookup;

        foreach my $asn (@as_list) {
            $as_set{$asn} = $asn;
        }

        $logger->auto("CONNECTIVITY:V6_ANNOUNCED_BY_ASN",
            $address, join(",", @as_list));

        # REQUIRE: A name server should not be announced by more than one AS
        # REQUIRE: A name server must be announced
        if (scalar @as_list > 1) {
            $logger->auto("CONNECTIVITY:V6_MULTIPLE_ASN", $address);
        } elsif (scalar @as_list < 1) {
            $errors += $logger->auto("CONNECTIVITY:V6_NOT_ANNOUNCED", $address);
        }
    }

    $logger->auto("CONNECTIVITY:V6_ASN_LIST", join(",", keys(%as_set)));

    # REQUIRE: Domain name servers should live in more than one AS
    my $as_count = scalar keys %as_set;
    if ($as_count <= 1) {
        $errors += $logger->auto("CONNECTIVITY:V6_TOO_FEW_ASN", $as_count);
    } else {
        $logger->auto("CONNECTIVITY:V6_ASN_COUNT_OK", $as_count);
    }

  DONE:
    return $errors;
}

1;

__END__


=head1 NAME

DNSCheck::Test::Connectivity - Test zone connectivity

=head1 DESCRIPTION

Test connectivity for a zone's nameservers. The following tests are made:

=over 4

=item *
A name server should not be announced by more than one AS.

=item *
A name server must be announced.

=item *
Domain name servers should live in more than one AS.

=back

=head1 METHODS

=over

=item ->test($zonename);

=back

=head1 EXAMPLES

=head1 SEE ALSO

L<DNSCheck>, L<DNSCheck::Logger>

=cut
