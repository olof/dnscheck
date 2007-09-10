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

die "syntax error" unless ($ARGV[0]);

$check->soa($ARGV[0]);
$check->report();
