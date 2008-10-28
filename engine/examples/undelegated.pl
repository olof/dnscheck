#!/usr/bin/perl
#
# $Id: soa.pl 523 2008-10-23 14:19:24Z calle $

require 5.008;
use warnings;
use strict;

use DNSCheck;

######################################################################

my $check = new DNSCheck({ interactive => 1 });

die "usage: $0 zone nameserver-ip1 nameserver-ip2 ..." unless (@ARGV > 1);

$check->zone->test_undelegated(@ARGV);
