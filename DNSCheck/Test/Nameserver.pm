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

######################################################################

sub test {
    my $context    = shift;
    my $zone       = shift;
    my $nameserver = shift;

    my $qclass = $context->qclass;
    my $logger = $context->logger;

    $logger->info("NAMESERVER:BEGIN", $zone, $nameserver);

    $logger->info("NAMESERVER:NOT_IMPLEMENTED");

    # TODO: implement
    #
    # NS points to valid hostname
    # NS should not be recursive
    # Routing information
    #  - report ASN or unannounced address
    #  - report inconsistent AS as-path
    # notice ICMP echo (ping) unreachability

    #*** nameserver for zone
    #
    # NS must be authoritative for zone [IIS.KVSE.001.01/r3,IIS.KVSE.001.01/r6]
    # NS must not point to CNAME
    # SOA fetchable over any protocol (UDP/TCP)
    # SOA fetchable over any listed transport (IPv4/IPv6)
    # inform whether AXFR is enabled or not

  DONE:
    $logger->info("NAMESERVER:END", $zone, $nameserver);
}

1;

__END__
