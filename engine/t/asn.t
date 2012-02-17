#!/usr/bin/perl -sw
#
# $Id$

require 5.008;
use warnings;
use strict;

use Test::More;
use MockResolver 'asn';
# use MockBootstrap;
use DNSCheck;

######################################################################

my $check = new DNSCheck({configfile => './t/config.yaml'});

######################################################################

ok(join(",", @{ $check->asn->lookup("195.47.254.0") }) eq "47698");
ok(join(",", @{ $check->asn->lookup("192.71.220.0") }) eq "1257");
ok(!$check->asn->lookup('gurksallad'), 'No response for bogus IP');
is_deeply($check->asn->lookup('192.168.12.12'), [], 'IPv4 not announced');
is_deeply($check->asn->lookup('2a00:801:f0:211::152'), [1257], 'IPv6 announced');
is_deeply($check->asn->lookup('3a00:801:f0:211::152'), [], 'IPv6 not announced');


my %tag = map {$_->[3] => 1} @{$check->logger->export};

foreach my $tag (qw[ASN:INVALID_ADDRESS ASN:NOT_ANNOUNCE ASN:ANNOUNCE_BY]) {
    ok($tag{$tag}, "Has $tag");
}

my $asn = $check->asn;
is($asn->parent,$check);
$asn->flush;
ok(!$asn->{asn}, 'Cache correctly flushed');

done_testing();