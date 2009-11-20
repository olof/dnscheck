#!/usr/bin/perl
#
# $Id$

require 5.008;
use warnings;
use strict;

use Test::More tests => 20;

use DNSCheck;

######################################################################

my $dc;
my %tag;

eval {
    $dc = new DNSCheck(
        { configfile => './config.yaml', rootsource => '212.247.18.3' });
};

ok(!$@, $@);

SKIP: {
    skip "Failed to get an object to test", 19 unless defined($dc);
    ok(defined($dc->soa->test("power.fine")));
    my @msg = @{ $dc->logger->{messages} };
    ok(scalar(@msg) == 67, "Total of " . scalar(@msg) . " messages.");
    %tag = map { $_->{tag}, $_ } @msg;
    foreach my $tag (
        qw[
        SOA:MNAME_VALID
        SOA:MNAME_PUBLIC
        SOA:MNAME_IS_AUTH
        MAIL:DELIVERY_IPV4_NOT_OK
        SOA:RNAME_UNDELIVERABLE
        SOA:TTL_OK
        SOA:REFRESH_OK
        SOA:RETRY_OK
        SOA:EXPIRE_OK
        SOA:MINIMUM_OK
        ]
      )
    {
        ok($tag{$tag}, "$tag found in results.");
    }

    $dc = new DNSCheck(
        { configfile => './config.yaml', rootsource => '212.247.18.3' });
    ok(defined($dc->soa->test("fail")));
    %tag = map { $_->{tag}, $_ } @{ $dc->logger->{messages} };
    foreach my $tag (
        qw[
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
