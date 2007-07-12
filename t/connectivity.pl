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

$check->connectivity("kirei.se");
$check->report();

$check->connectivity("pin.se");
$check->report();
