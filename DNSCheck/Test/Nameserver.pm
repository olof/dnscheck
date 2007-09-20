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

use DNSCheck::Test::Host;

######################################################################

sub test {
    my $context    = shift;
    my $zone       = shift;
    my $nameserver = shift;

    my $qclass = $context->qclass;
    my $logger = $context->logger;
    my $errors = 0;

    my $packet;

    $logger->info("NAMESERVER:BEGIN", $zone, $nameserver);

    # REQUIRE: Nameserver must be a valid hostname
    if (DNSCheck::Test::Host::test($context, $nameserver)) {
        $logger->error("NAMESERVER:HOST_ERROR", $nameserver);
        $errors++;
        goto DONE;
    }

    my @addresses = $context->dns->find_addresses($nameserver, $qclass);

  ADDRESS: foreach my $address (@addresses) {

        # REQUIRE: Nameserver should not be recursive
        $logger->debug("NAMESERVER:CHECKING_RECURSION", $nameserver, $address);
        if ($context->dns->address_is_recursive($address, $qclass)) {
            $logger->warning("NAMESERVER:RECURSIVE", $nameserver, $address);
        } else {
            $logger->info("NAMESERVER:NOT_RECURSIVE", $nameserver, $address);
        }

        # REQUIRE: Nameserver must be authoritative for the zone
        #          [IIS.KVSE.001.01/r3,IIS.KVSE.001.01/r6]
        $logger->debug("NAMESERVER:CHECKING_AUTH", $nameserver, $address);
        if ($context->dns->address_is_authoritative($address, $zone, $qclass)) {
            $logger->error("NAMESERVER:NOT_AUTH", $nameserver, $address, $zone);
            $errors++;
            next ADDRESS;
        } else {
            $logger->info("NAMESERVER:AUTH", $nameserver, $address, $zone);
        }

        # REQUIRE: SOA must be fetchable over any protocol (UDP/TCP)
        $logger->debug("NAMESERVER:CHECKING_UDP", $nameserver, $address);
        $packet =
          $context->dns->query_explicit($zone, $qclass, "SOA", $address,
            { transport => "udp" });
        if ($packet) {
            $logger->info("NAMESERVER:UDP_OK", $nameserver, $address, $zone);
        } else {
            $logger->error("NAMESERVER:NO_UDP", $nameserver, $address, $zone);
            $errors++;
        }

        $logger->debug("NAMESERVER:CHECKING_TCP", $nameserver, $address);
        $packet =
          $context->dns->query_explicit($zone, $qclass, "SOA", $address,
            { transport => "tcp" });
        if ($packet) {
            $logger->info("NAMESERVER:TCP_OK", $nameserver, $address, $zone);
        } else {
            $logger->error("NAMESERVER:NO_TCP", $nameserver, $address, $zone);
            $errors++;
        }

        # REQUIRE: SOA may provide AXFR
        # TODO: SOA may provide AXFR
    }

  DONE: $logger->info("NAMESERVER:END", $zone, $nameserver);
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

test(I<context>, I<zone>, I<nameserver>);

=head1 EXAMPLES

    use DNSCheck::Context;
    use DNSCheck::Test::Nameserver;

    my $context = new DNSCheck::Context("IN");
    DNSCheck::Test::Nameserver::test($context, "se", "a.ns.se");
    $context->logger->dump();

=head1 SEE ALSO

L<DNSCheck>, L<DNSCheck::Context>, L<DNSCheck::Logger>,
L<DNSCheck::Test::Host>

=cut
