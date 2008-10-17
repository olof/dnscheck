#!/usr/bin/perl -sw
#
# $Id$

require 5.8.0;
use warnings;
use strict;

use Test::More tests => 3;

use DNSCheck;

######################################################################

my $check = new DNSCheck();

######################################################################

ok($check->address->test("192.36.144.107") == 0);
ok($check->address->test("2a01:3f0:0:301::53") == 0);
ok($check->address->test("127.0.0.1") == 1);