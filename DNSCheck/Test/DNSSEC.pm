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

package DNSCheck::Test::DNSSEC;

require 5.8.0;
use warnings;
use strict;

use Net::DNS 0.57;
use Net::DNS::SEC 0.14;
use Data::Dumper;
use Date::Parse;
use POSIX qw(strftime);

######################################################################

sub test {
    my $context = shift;
    my $zone    = shift;

    my $qclass = $context->qclass;
    my $logger = $context->logger;
    my $errors = 0;

    my $packet;

    $logger->info("DNSSEC:BEGIN", $zone);

    my $child_ns = $context->dns->get_nameservers_ipv4($zone, $qclass);

    $errors += _test_child($context, $zone, $child_ns->[0]);

    if ($errors) {
        goto DONE;
    }

    #my $parent    = $context->dns->find_parent($zone, $qclass);
    #my $parent_ns = $context->dns->get_nameservers_ipv4($parent, $qclass);
    #$errors += _test_parent($context, $zone, $parent_ns->[0]);

    # TODO: implement
    #
    # if DS at parent, child MUST use DNSSEC
    # there MAY exist a DNSKEY at the child (or we are not doing DNSSEC)
    # a DNSSEC key SHOULD NOT be of type RSA/MD5
    # at least one DNSKEY SHOULD be RSA/SHA1
    # there MAY exist a KSK at the child
    # if KSK is used, there should be a ZSK
    # RRSIG(DNSKEY) MUST be valid and created by a valid DNSKEY (inklusive KSK)
    # RRSIG(SOA) MUST be valid and created by a valid DNSKEY (ZSK if KSK used)
    # there MAY exist a DS at parent (or we do not have a secure delegation)
    # the DS MUST point to a DNSKEY signing the child's DNSKEY RRset
    # the DS MAY point to a KSK at the child
    # at least one DS algorithm SHOULD be of type RSA/SHA1

  DONE:
    $logger->info("DNSSEC:END", $zone);
    return $errors;
}

sub _test_child {
    my $context = shift;
    my $zone    = shift;
    my $ns      = shift;

    my $qclass = $context->qclass;
    my $logger = $context->logger;
    my $errors = 0;

    my %flags = (dnssec => 1);

    my $packet =
      $context->dns->query_explicit($zone, $qclass, "DNSKEY", $ns, "tcp",
        \%flags);

    return unless ($packet);

    my $answer = _dissect($packet, "DNSKEY");

   # REQUIRE: there may exist a DNSKEY at the child (or we are not doing DNSSEC)
    if ($#{ @{ $answer->{DNSKEY} } } >= 0) {
        $logger->info("DNSSEC:DNSKEY_FOUND");
    } else {
        $logger->info("DNSSEC:NO_DNSKEY_FOUND");
        $errors++;
        goto DONE;
    }

  DONE:
    return $errors;
}

sub _test_parent {
    my $context = shift;
    my $zone    = shift;
    my $ns      = shift;

    return 0;
}

sub _dissect {
    my $packet = shift;
    my $qtype  = shift;

    my %response = ();

    foreach my $rr ($packet->answer) {
        if (    $rr->type eq "RRSIG"
            and $qtype ne "RRSIG"
            and $rr->typecovered eq $qtype)
        {
            push @{ $response{RRSIG} }, $rr;
            next;
        }

        if ($rr->type eq $qtype) {
            push @{ $response{$qtype} }, $rr;
            next;
        }
    }

    if ($#{ $response{$qtype} } < 0) {
        return undef;
    }

    return \%response;

}

1;

__END__
