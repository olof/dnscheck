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

package DNSCheck::Test::SOA;

require 5.8.0;
use warnings;
use strict;

use DNSCheck::Test::Host;
use DNSCheck::Test::Mail;

######################################################################

sub test {
    my $context = shift;
    my $zone    = shift;

    my $qclass = $context->qclass;
    my $logger = $context->logger;
    my $errors = 0;

    $logger->info("SOA:BEGIN", $zone);

    # FIXME: this query should be directed to a child
    my $packet = $context->dns->query_child($zone, $qclass, "SOA");

    # REQUIRE: SOA record must exist
    unless ($packet->header->ancount) {
        $logger->error("SOA:NOT_FOUND", $zone);
        return $errors;
        goto DONE;
    } else {
        ## TODO: add positives
    }

    # REQUIRE: only ONE SOA record may exist
    unless ($packet->header->ancount == 1) {
        $logger->error("SOA:MULTIPLE_SOA", $zone);
        return $errors;
        goto DONE;
    }

    my @answer = $packet->answer;
    my $soa    = $answer[0];

    # REQUIRE: SOA MNAME must exist as a valid hostname
    if (DNSCheck::Test::Host::test($context, $soa->mname) > 0) {
        $logger->error("SOA:MNAME_ERROR", $zone);
    }

    $packet = $context->dns->query_resolver($zone, $qclass, "NS");

    unless ($packet->header->ancount) {
        $logger->error("SOA:NS_NOT_FOUND", $zone);
        goto DONE;
    }

    # REQUIRE: SOA MNAME may not be in the list of nameservers
    unless (mname_is_ns($soa, $packet->answer)) {
        $logger->notice("SOA:MNAME_STEALTH", $zone, $soa->mname);
    } else {
        $logger->notice("SOA:MNAME_PUBLIC", $zone, $soa->mname);
    }

    # REQUIRE: SOA MNAME may be unreachable
    # REQUIRE: SOA MNAME must be authoritative
    #if ($context->dns->mname_is_auth($zone, $qclass) > 0) {
    if (mname_is_auth($soa, $context) > 0) {
        $logger->warning("SOA:MNAME_NOT_AUTH", $zone, $soa->mname);
    }

    # REQUIRE: SOA RNAME must have a valid syntax (@ vs .)
    # REQUIRE: SOA RNAME address should be deliverable
    if ($soa->rname =~ /^(.+?)(?<!\\)\.(.+)$/) {
        my $mailaddr = $soa->rname;
        $mailaddr =~ s/(?<!\\)\./@/;
        $mailaddr =~ s/\\\././g;

        if (DNSCheck::Test::Mail::test($context, $mailaddr)) {
            $logger->warning("SOA:RNAME_DELIVER", $zone, $soa->rname,
                $mailaddr);
        }
    } else {
        $logger->error("SOA:RNAME_SYNTAX", $zone, $soa->rname);
        $errors++;
    }

    # REQUIRE: SOA TTL advistory, min 1 hour
    my $min_soa_ttl = 3600;
    if ($soa->ttl < $min_soa_ttl) {
        $logger->warning("SOA:TTL", $zone, $min_soa_ttl);
    }

    # REQUIRE: SOA 'refresh' at least 4 hours
    my $min_soa_refresh = 4 * 3600;
    if ($soa->refresh < $min_soa_refresh) {
        $logger->warning("SOA:REFRESH", $zone, $min_soa_refresh);
    }

    # REQUIRE: SOA 'retry' lower than 'refresh'
    unless ($soa->retry < $soa->refresh) {
        $logger->warning("SOA:RETRY_LOWER_REFRESH", $zone);
    }

    # REQUIRE: SOA 'retry' at least 1 hour
    my $min_soa_retry = 3600;
    if ($soa->retry < $min_soa_retry) {
        $logger->warning("SOA:RETRY", $zone, $min_soa_retry);
    }

    # REQUIRE: SOA 'expire' at least 7 days
    my $min_soa_expire = 7 * 24 * 3600;
    if ($soa->expire < $min_soa_expire) {
        $logger->warning("SOA:EXPIRE", $zone, $min_soa_expire);
    }

    # REQUIRE: SOA 'expire' at least 7 times 'refresh'
    if ($soa->expire < $soa->refresh * 7) {
        $logger->warning("SOA:EXPIRE_VS_REFRESH", $zone);
    }

    # REQUIRE: SOA 'minimum' less than 1 day
    my $max_soa_minimum = 24 * 3600;
    if ($soa->minimum > $max_soa_minimum) {
        $logger->warning("SOA:MINIMUM", $zone, $max_soa_minimum);
    }

  DONE:
    $logger->info("SOA:END", $zone);

    return $errors;
}

sub mname_is_ns {
    my $soa = shift;
    my @ns  = @_;

    foreach my $rr (@ns) {
        if ($rr->nsdname eq $soa->mname) {
            return 1;
        }
    }

    return 0;
}

sub mname_is_auth {
    my $soa     = shift;
    my $context = shift;

    my $dns    = $context->{dns};
    my $logger = $context->{logger};
    my $errors = 0;

    my $ipv4 = $dns->query_resolver($soa->mname, $soa->class, "A");
    my $ipv6 = $dns->query_resolver($soa->mname, $soa->class, "AAAA");

    unless ($ipv4->header->ancount || $ipv6->header->ancount) {
        $errors++;
        goto DONE;
    }

    my $resolver = new Net::DNS::Resolver;
    $resolver->recurse(0);

    my @addresses = ();
    push @addresses, $ipv4->answer if ($ipv4->header->ancount);
    push @addresses, $ipv6->answer if ($ipv6->header->ancount);

    foreach my $address (@addresses) {
        if ($address) {
            $resolver->nameservers($address->address);
            $logger->debug("SOA:MNAME_QUERY", $soa->name, $address->address);

            my $answer = $resolver->send($soa->name, "SOA", $soa->class);

            unless ($answer) {
                $logger->debug("SOA:MNAME_QUERY_TIMEOUT");

                # FIXME: should query timeout be an error?
                # $errors++;
                next;
            }

            unless ($answer->header->aa) {
                $errors++;
                $logger->debug("SOA:MNAME_QUERY_NOT_AUTH", $address->address);
            }

            $logger->debug("SOA:MNAME_QUERY_AUTH", $address->address);
        }
    }

  DONE:
    return $errors;
}

1;

__END__
