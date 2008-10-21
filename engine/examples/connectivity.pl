#!/usr/bin/perl
#
# $Id$

require 5.8.0;
use warnings;
use strict;

use DNSCheck;

######################################################################

my $check = new DNSCheck({ interactive => 1 });

die "syntax error" unless ($ARGV[0]);

$check->connectivity->test($ARGV[0]);
