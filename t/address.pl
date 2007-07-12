#!/usr/bin/perl
#
# $Id$

require 5.8.0;
use warnings;
use strict;

use Data::Dumper;

use DNSCheck;

######################################################################

my $check = new DNSCheck("IN");

$check->address("195.47.254.10");
$check->address("195.47.254.256");
$check->address("195.47.254.4");
$check->address("10.0.0.1");
$check->address("224.1.2.3");
$check->address("::1");
$check->address("fe80::1");
$check->address("::ffff:10.0.0.1");
$check->address("2001:0db8::dead:beef");
$check->address("2001:670:87:11::182");

$check->report();
