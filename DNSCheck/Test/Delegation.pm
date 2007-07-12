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

package DNSCheck::Test::Delegation;

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

    $logger->info("DELEGATION:BEGIN", $zone);

    my $packet;

    my @ns_at_parent = $context->dns->get_nameservers_at_parent($zone, $qclass);
    if (scalar @ns_at_parent) {
        $logger->info("DELEGATION:NS_AT_PARENT", join(",", @ns_at_parent));
    } else {
        $logger->error("DELEGATION:NOT_FOUND_AT_PARENT", $zone);
        $errors++;
    }

    my @ns_at_child = $context->dns->get_nameservers_at_child($zone, $qclass);
    if (scalar @ns_at_child) {
        $logger->info("DELEGATION:NS_AT_CHILD", join(",", @ns_at_child));
    } else {
        $logger->error("DELEGATION:NOT_FOUND_AT_CHILD", $zone);
        $errors++;
    }

    # REQUIRE: all NS at parent must exist at child [IIS.KVSE.001.01/r2]
    foreach my $ns (@ns_at_parent) {
        unless (scalar grep(/^$ns$/, @ns_at_child)) {
            $logger->error("DELEGATION:EXTRA_NS_PARENT", $ns);
            $errors++;
        }
    }

    # REQUIRE: all NS at child may exist at parent
    foreach my $ns (@ns_at_child) {
        unless (scalar grep(/^$ns$/, @ns_at_parent)) {
            $logger->warning("DELEGATION:EXTRA_NS_CHILD+", $ns);
            $errors++;
        }
    }

    # REQUIRE: at least two (2) NS records at parent [IIS.KVSE.001.01/r1]
	unless (scalar @ns_at_parent >= 2) {
		$logger->error("DELEGATION:TOO_FEW_NS", $zone);
	}

	# TODO: check for inconsistent glue

	# TODO: check for loop in glue record chain (i.e. unresolvable)
	
	# TODO: warning if glue chain is longer than 3 lookups

  DONE:
    $logger->info("DELEGATION:END", $zone);

    return $errors;
}

######################################################################

sub _get_ns_at_parent {
    my $context = shift;
    my $zone    = shift;

    my $qclass = $context->qclass;
    my @ns;

    my $packet = $context->dns->query_parent($zone, $qclass, "NS");

    foreach my $rr ($packet->authority) {
        if ($rr->type eq "NS") {
            push @ns, $rr->nsdname;
        }
    }

    return sort(@ns);
}

sub _get_ns_at_child {
    my $context = shift;
    my $zone    = shift;

    my $qclass = $context->qclass;
    my @ns;

    my $packet = $context->dns->query_child($zone, $qclass, "NS");

    foreach my $rr ($packet->answer) {
        if ($rr->type eq "NS") {
            push @ns, $rr->nsdname;
        }
    }

    return sort(@ns);
}

1;

__END__
