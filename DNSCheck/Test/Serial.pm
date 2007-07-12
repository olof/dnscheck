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

package DNSCheck::Test::Serial;

require 5.8.0;
use warnings;
use strict;

######################################################################

sub test {
    my $context = shift;
    my $zone    = shift;

    my $qclass = $context->qclass;
    my $logger = $context->logger;
    my $errors = 0;

    $logger->info("SERIAL:BEGIN", $zone);

    # TODO: implement

    # Fetch IPv4/IPv6 nameservers
    my $ipv4 = $context->dns->get_nameservers_ipv4($zone, $qclass);
    my $ipv6 = $context->dns->get_nameservers_ipv6($zone, $qclass);

    my %serial_counter;

    foreach my $address (@{$ipv4}) {
        my $packet =
          $context->dns->query_explicit($zone, $qclass, "SOA", $address);

        next unless ($packet);
        next unless ($packet->header->ancount == 1);
        my @rr_set = $packet->answer;
        next unless ($rr_set[0]->type eq "SOA");

        my $serial = $rr_set[0]->serial;

        $logger->debug("SERIAL:SOA_AT_ADDRESS", $address, $serial);

        $serial_counter{$serial}++;
    }

    my $different = scalar keys %serial_counter;

    if ($different > 1) {
        $logger->warning("SERIAL:DIFFERENT", $different);
    }

  DONE:
    $logger->info("SERIAL:END", $zone);

    return 0;
}

1;

__END__
