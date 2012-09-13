#!/usr/bin/perl
#
# $Id$

require 5.008;
use warnings;
use strict;

use Test::More;
use lib "t/lib";

use MockResolver 'soa';
use DNSCheck;

######################################################################

my $dc;
my %tag;

eval {
    $dc = new DNSCheck(
        { configdir => './t/config' });
};

ok(!$@, $@);

SKIP: {
    skip "Failed to get an object to test", 19 unless defined($dc);
    $dc->config->{disable}{mail}{test} = 0;
    ok(defined($dc->soa->test("iis.se")));
    my @msg = @{ $dc->logger->{messages} };
    ok(scalar(@msg) >= 60, "Total of " . scalar(@msg) . " messages.");
    %tag = map { $_->{tag} => 1 } @msg;
    foreach my $tag (
        qw[
        SOA:FOUND
        SOA:MNAME_VALID
        SOA:MNAME_PUBLIC
        SOA:MNAME_IS_AUTH
        MAIL:DELIVERY_IPV4_OK
        SOA:RNAME_DELIVERABLE
        SOA:TTL_OK
        SOA:REFRESH_OK
        SOA:RETRY_OK
        SOA:EXPIRE_OK
        SOA:MINIMUM_OK
        SOA:MNAME_PUBLIC
        ]
      )
    {
        ok($tag{$tag}, "$tag found in results.");
    }

    $dc = new DNSCheck(
        { configdir => './t/config' });
        $dc->config->{disable}{mail}{test} = 0;
    ok(defined($dc->soa->test("nic.se")));
    %tag = map { $_->{tag} => 1} @{ $dc->logger->{messages} };
    foreach my $tag (
        qw[
        SOA:FOUND
        SOA:RETRY_SMALL
        SOA:MNAME_ERROR
        SOA:EXPIRE_SMALL
        SOA:EXPIRE_VS_REFRESH
        SOA:MINIMUM_SMALL
        SOA:RNAME_UNDELIVERABLE
        ]
      )
    {
        ok($tag{$tag}, "$tag found in results.");
    }
}

done_testing;
