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

package DNSCheck::Test::Nameserver;

require 5.8.0;
use warnings;
use strict;

use Net::IP 1.25 qw(ip_get_version);

######################################################################

sub test {
    my $proto      = shift;    # Not used
    my $parent     = shift;
    my $zone       = shift;
    my $nameserver = shift;

    my $qclass = $parent->config->get("dns")->{class};
    my $logger = $parent->logger;
    my $errors = 0;

    my $packet;

    $logger->module_stack_push();
    $logger->auto("NAMESERVER:BEGIN", $nameserver);

    # REQUIRE: Nameserver must be a valid hostname
    if ($parent->host($nameserver)) {
        $errors += $logger->auto("NAMESERVER:HOST_ERROR", $nameserver);
        goto DONE;
    }

    my @addresses = $parent->dns->find_addresses($nameserver, $qclass);

    $errors += _test_ip($parent, $zone, $nameserver, @addresses);

  DONE:
    $logger->auto("NAMESERVER:END", $nameserver);
    $logger->module_stack_pop();

    return $errors;
}

sub test_by_ip {
    my $proto      = shift;    # Not used
    my $parent     = shift;
    my $zone       = shift;
    my $nameserver = shift;

    my $qclass = $parent->config->get("dns")->{class};
    my $logger = $parent->logger;
    my $errors = 0;

    my $packet;

    $logger->module_stack_push();
    $logger->auto("NAMESERVER:BEGIN", $nameserver);

    $errors += _test_ip($parent, $zone, $nameserver, $nameserver);

  DONE:
    $logger->auto("NAMESERVER:END", $nameserver);
    $logger->module_stack_pop();

    return $errors;
}

sub _test_ip {
    my $parent     = shift;
    my $zone       = shift;
    my $nameserver = shift;
    my @addresses  = @_;

    my $qclass = $parent->config->get("dns")->{class};
    my $logger = $parent->logger;
    my $errors = 0;

    my $packet;

  ADDRESS: foreach my $address (@addresses) {

        my $skip_udp = 0;
        my $skip_tcp = 0;

        if (ip_get_version($address) == 4
            && !$parent->config->get("net")->{ipv4})
        {
            $logger->auto("NAMESERVER:SKIPPED_IPV4", $address);
            next ADDRESS;
        }

        if (ip_get_version($address) == 6
            && !$parent->config->get("net")->{ipv6})
        {
            $logger->auto("NAMESERVER:SKIPPED_IPV6", $address);
            next ADDRESS;
        }

        # REQUIRE: Nameserver should not be recursive
        $logger->auto("NAMESERVER:CHECKING_RECURSION", $nameserver, $address);
        if ($parent->dns->address_is_recursive($address, $qclass)) {
            $logger->auto("NAMESERVER:RECURSIVE", $nameserver, $address);
        } else {
            $logger->auto("NAMESERVER:NOT_RECURSIVE", $nameserver, $address);
        }

        # REQUIRE: Nameserver must be authoritative for the zone
        #          [IIS.KVSE.001.01/r3,IIS.KVSE.001.01/r6]
        $logger->auto("NAMESERVER:CHECKING_AUTH", $nameserver, $address);
        if ($parent->dns->address_is_authoritative($address, $zone, $qclass)) {
            $errors +=
              $logger->auto("NAMESERVER:NOT_AUTH", $nameserver, $address,
                $zone);
            next ADDRESS;
        } else {
            $logger->auto("NAMESERVER:AUTH", $nameserver, $address, $zone);
        }

        # REQUIRE: SOA must be fetchable over any protocol (UDP/TCP)
        $logger->auto("NAMESERVER:TESTING_UDP", $nameserver, $address);
        $packet =
          $parent->dns->query_explicit($zone, $qclass, "SOA", $address,
            { transport => "udp", aaonly => 0 });
        if ($packet) {
            $logger->auto("NAMESERVER:UDP_OK", $nameserver, $address, $zone);
        } else {
            $errors +=
              $logger->auto("NAMESERVER:NO_UDP", $nameserver, $address, $zone);
            $skip_udp = 1;
        }

        $logger->auto("NAMESERVER:TESTING_TCP", $nameserver, $address);
        $packet =
          $parent->dns->query_explicit($zone, $qclass, "SOA", $address,
            { transport => "tcp", aaonly => 0 });
        if ($packet) {
            $logger->auto("NAMESERVER:TCP_OK", $nameserver, $address, $zone);
        } else {
            $errors +=
              $logger->auto("NAMESERVER:NO_TCP", $nameserver, $address, $zone);
            $skip_tcp = 1;
        }

        # REQUIRE: Nameserver may provide AXFR
        $logger->auto("NAMESERVER:TESTING_AXFR", $nameserver, $address);
        if ($skip_tcp) {
            $logger->auto("NAMESERVER:AXFR_SKIP", $nameserver, $address, $zone);
        } else {
            if ($parent->dns->check_axfr($address, $zone, $qclass)) {
                $logger->auto("NAMESERVER:AXFR_OPEN", $nameserver, $address,
                    $zone);
            } else {
                $logger->auto("NAMESERVER:AXFR_CLOSED",
                    $nameserver, $address, $zone);
            }
        }

        # Check for possible identification
        unless ($skip_tcp || $skip_udp) {
            $logger->auto("NAMESERVER:CHECKING_LEGACY_ID",
                $nameserver, $address);
            _check_id($parent, $nameserver, $address);
        } else {
            $logger->auto("NAMESERVER:LEGACY_ID_SKIP", $nameserver, $address);
        }

        # FIXME: remove comment once query_nsid is complete
        #$logger->auto("NAMESERVER:CHECKING_NSID", $nameserver, $address);
        #my $nsid = $parent->dns->query_nsid($address, $zone, $qclass, "SOA");
        #if ($nsid) {
        #    $logger->auto("NAMESERVER:NSID", $nameserver, $address, $nsid);
        #}
    }

    return $errors;
}

sub _check_id {
    my $parent     = shift;
    my $nameserver = shift;
    my $address    = shift;

    my $qclass = $parent->config->get("dns")->{class};
    my $logger = $parent->logger;

    my @domains =
      ("hostname.bind", "version.bind", "id.server", "version.server");

    my $packet;

    for my $domain (@domains) {
        $packet = $parent->dns->query_explicit($domain, "CH", "TXT", $address);

        if ($packet) {
            next unless ($packet);

            foreach my $rr ($packet->answer) {
                next unless (($rr->type eq "TXT") && $rr->txtdata);

                $logger->auto("NAMESERVER:LEGACY_ID", $nameserver, $address,
                    $domain, $rr->txtdata);
            }
        }
    }
}

1;

__END__


=head1 NAME

DNSCheck::Test::Nameserver - Test a single nameserver

=head1 DESCRIPTION

Test a single name server for a specific zone. The following tests are made:

=over 4

=item *
The nameserver must be a valid hostname.

=item *
The nameserver should not be recursive.

=item *
The nameserver must be authoritative for the zone.

=item *
The SOA record for the zone must be fetchable over both UDP and TCP.

=item *
The nameserver may provide AXFR for the zone.

=back

=head1 METHODS

test(I<parent>, I<zone>, I<nameserver>);

=head1 EXAMPLES

=head1 SEE ALSO

L<DNSCheck>, L<DNSCheck::Logger>, L<DNSCheck::Test::Host>

=cut
