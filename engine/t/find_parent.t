#!/usr/bin/perl -sw
#
# $Id$

require 5.008;
use warnings;
use strict;

use Test::More tests => 9;

use DNSCheck;

######################################################################

my $check = new DNSCheck;
my $dns   = $check->dns;

######################################################################

my $start = time();
ok(!$dns->find_parent("6f3899904701b0ce2835d82493c0212babf875c7", "IN"));
ok($dns->find_parent("se",           "IN") eq ".");
ok($dns->find_parent("iis.se",       "IN") eq "se");
ok($dns->find_parent("narnia.pp.se", "IN") eq "se");
ok($dns->find_parent("example.com",  "IN") eq "com");
ok($dns->find_parent("brixtal.se",   "IN") eq "se");
ok($dns->find_parent("tboerner.eu",  "IN") eq "eu");
ok($dns->find_parent("0.0.f.f.8.d.6.1.1.0.0.2.ip6.arpa", "IN") eq 'f.f.8.d.6.1.1.0.0.2.ip6.arpa');
my $diff = time() - $start;
ok($diff < 30, "Test ran in $diff seconds");
