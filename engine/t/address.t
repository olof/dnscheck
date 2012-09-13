#!/usr/bin/perl -sw
#
# $Id$

require 5.008;
use warnings;
use strict;

use Test::More;
use lib "t/lib";

use MockResolver 'address';

use DNSCheck;

######################################################################

my $check = new DNSCheck({configdir => './t/config'});

######################################################################

sub has {
    my $tag = shift;
    ok(scalar(grep {$_->[3] eq $tag} @{$check->logger->export}) > 0, "Has $tag");
    $check->logger->clear;
}

ok($check->address->test("192.36.144.107") == 0);
$check->logger->clear;

ok($check->address->test("2a01:3f0:0:301::53") == 0);
$check->logger->clear;

ok($check->address->test("127.0.0.1") == 1);
has('ADDRESS:RESERVED_IPV4');

ok($check->address->test("172.18.18.18") == 1);
has('ADDRESS:PRIVATE_IPV4');

ok($check->address->test("::1") == 1);
has('ADDRESS:RESERVED_IPV6');

ok($check->address->test("2a01:3f0:0:301::54") == 0);
has('ADDRESS:PTR_NOT_FOUND');

ok($check->address->test('178.16.223.169') == 0);
has('ADDRESS:PTR_HOSTNAME_NOT_FOUND');

done_testing();
