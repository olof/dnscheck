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

require 5.8.0;
use warnings;
use strict;

######################################################################

sub test {
    my $context = shift;
    my $zone    = shift;

    my $qclass = $context->qclass;
    my $logger = $context->logger;

    $logger->info("CONNECTIVITY:BEGIN", $zone);

    my %as_set;

	# Fetch IPv4 nameservers
	# FIXME: AS lookup for IPv6 addresses
    my $ipv4 = $context->dns->get_nameservers_ipv4($zone, $qclass);

    foreach my $address (@{$ipv4}) {
        foreach my $asn (@{ $context->asn->lookup($address) }) {
            $as_set{$asn} = $asn;
        }
    }

    $logger->info("CONNECTIVITY:ANNOUNCED_BY_AS", join(",", keys(%as_set)));

    # REQUIRE: Domain name servers should live in more than one AS
    my $as_count = scalar keys %as_set;
    if ($as_count > 1) {
	    $logger->info("CONNECTIVITY:ANNOUNCED_BY_OK", $as_count);
    } else {
	    $logger->warning("CONNECTIVITY:ANNOUNCED_BY_TOO_FEW", $as_count);
    }

  DONE:
    $logger->info("CONNECTIVITY:END", $zone);
}

1;

__END__
