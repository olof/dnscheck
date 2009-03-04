#!/usr/bin/perl
#
# $Id$

require 5.008;
use warnings;
use strict;

use DNSCheck;

######################################################################

my $check = new DNSCheck({ interactive => 1, extras => { debug => 1 } });

die "usage: $0 zonename\n" unless ($ARGV[0]);

$check->soa->test($ARGV[0]);
