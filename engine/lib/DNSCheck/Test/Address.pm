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

package DNSCheck::Test::Address;

require 5.010001;
use warnings;
use strict;

use base 'DNSCheck::Test::Common';

use Net::IP 1.25;

######################################################################

our @private_ipv4  = ();
our @reserved_ipv4 = ();
our @reserved_ipv6 = ();

# REQUIRE: Private IPv4 Addresses (RFC 1918)
push @private_ipv4, new Net::IP("10.0.0.0/8");
push @private_ipv4, new Net::IP("172.16.0.0/12");
push @private_ipv4, new Net::IP("192.168.0.0/16");

# REQUIRE: Special-Use IPv4 Addresses (RFC 3330)
push @reserved_ipv4, new Net::IP("127.0.0.0/8");
push @reserved_ipv4, new Net::IP("224.0.0.0/4");
push @reserved_ipv4, new Net::IP("0.0.0.0/8");
push @reserved_ipv4, new Net::IP("169.254.0.0/16");
push @reserved_ipv4, new Net::IP("192.0.2.0/24");
push @reserved_ipv4, new Net::IP("192.88.99.0/24");
push @reserved_ipv4, new Net::IP("198.18.0.0/15");
push @reserved_ipv4, new Net::IP("240.0.0.0/4");

# REQUIRE: Special-Use IPv4 Addresses (RFC 5735)
push @reserved_ipv4, new Net::IP("198.51.100.0/24");
push @reserved_ipv4, new Net::IP("203.0.113.0/24");
push @reserved_ipv4, new Net::IP("192.0.0.0/24");
push @reserved_ipv4, new Net::IP("255.255.255.255/32");

# REQUIRE: Special-Use IPv6 Addresses (RFC 5156)
push @reserved_ipv6, new Net::IP("::1/128");
push @reserved_ipv6, new Net::IP("ff00::/8");
push @reserved_ipv6, new Net::IP("::/128");
push @reserved_ipv6, new Net::IP("::ffff:0:0/96");
push @reserved_ipv6, new Net::IP("fe80::/10");
push @reserved_ipv6, new Net::IP("fc00::/7");
push @reserved_ipv6, new Net::IP("2001:0db8::/32");
push @reserved_ipv6, new Net::IP("2001:10::/28");

# Discard-Only (RFC6666)
push @reserved_ipv6, new Net::IP('0100::/64');

# REQUIRE: Special-Use IPv4 Addresses (RFC 6598)

push @reserved_ipv4, new Net::IP('100.64.0.0/10');

######################################################################

sub test {
    my $self    = shift;
    my $parent  = $self->parent;
    my $address = shift;

    return 0 unless $parent->config->should_run;

    my $qclass = $self->qclass;
    my $logger = $parent->logger;
    my $errors = 0;

    $logger->module_stack_push();
    $logger->auto("ADDRESS:BEGIN", $address);

    # REQUIRE: Address must be syntactically correct
    my $ip = new Net::IP($address);
    unless ($ip) {
        $errors += $logger->auto("ADDRESS:INVALID", $address);
        goto DONE;
    }

    # REQUIRE: Do not allow private IPv4 Addresses
    if ($ip->version == 4) {
        foreach my $prefix (@private_ipv4) {
            if ($ip->overlaps($prefix)) {
                $errors += $logger->auto("ADDRESS:PRIVATE_IPV4", $address);
                goto DONE;
            }
        }
    }

    # REQUIRE: Do not allow reserved IPv4 Addresses
    if ($ip->version == 4) {
        foreach my $prefix (@reserved_ipv4) {
            if ($ip->overlaps($prefix)) {
                $errors += $logger->auto("ADDRESS:RESERVED_IPV4", $address);
                goto DONE;
            }
        }
    }

    # REQUIRE: Do not allow reserved IPv6 Addresses
    if ($ip->version == 6) {
        foreach my $prefix (@reserved_ipv6) {
            if ($ip->overlaps($prefix)) {
                $errors += $logger->auto("ADDRESS:RESERVED_IPV6", $address);
                goto DONE;
            }
        }
    }

    # REQUIRE: PTR should exist for address
    my $reverse = $ip->reverse_ip();
    my $ptr = $parent->dns->query_resolver($reverse, $qclass, "PTR");

    unless ($ptr && $ptr->header->ancount) {
        $logger->auto("ADDRESS:PTR_NOT_FOUND", $address, $reverse);
    } else {

        # REQUIRE: Hostname in PTR should exist
        # FIXME: check that at least one name points back to $address
        my @ptrlist = ();
        foreach my $p ($ptr->answer) {
            next unless (($p->type eq "PTR") && $p->ptrdname);
            push @ptrlist, $p->ptrdname;
        }
        foreach my $hostname (sort @ptrlist) {
            my $ipv4 = $parent->dns->query_resolver($hostname, $qclass, "A");
            my $ipv6 = $parent->dns->query_resolver($hostname, $qclass, "AAAA");

            unless (($ipv4 && $ipv4->header->ancount)
                || ($ipv6 && $ipv6->header->ancount))
            {
                $logger->auto("ADDRESS:PTR_HOSTNAME_NOT_FOUND",
                    $address, $hostname);
                goto DONE;
            }
        }
    }

  DONE:
    $logger->auto("ADDRESS:END", $address);
    $logger->module_stack_pop();

    return $errors;
}

1;

__END__


=head1 NAME

DNSCheck::Test::Address - Test for valid IP addresses

=head1 DESCRIPTION

Tests for valid (and resonable) IP addresses. The following tests are made:

=over 4

=item *
Addresses must be syntactically correct.

=item *
Private IPv4 Addresses (RFC 1918) must not be used.

=item *
Special-Use IPv4 Addresses (RFC 3330)  must not be used.

=item *
Special-Use IPv6 Addresses must not be used.

=item *
There should exist a PTR record for the address.

=item *
The hostname(s) pointed to by the PTR record(s) should exist.

=back

=head1 METHODS

=head2 test(I<parent>, I<address>);

=head1 EXAMPLES

    use DNSCheck;


=head1 SEE ALSO

L<DNSCheck>, L<DNSCheck::Logger>

=cut
