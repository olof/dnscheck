#!/usr/bin/perl
#
# $Id$

require 5.008;
use warnings;
use strict;

use Data::Dumper;

use DNSCheck;

######################################################################

my $check = DNSCheck->new({ interactive => 1, extras => {debug => 1}, locale => "en" });

die "syntax error" unless ($ARGV[0]);

$check->asn->lookup($ARGV[0]);
