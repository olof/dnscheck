#!/usr/bin/perl
#
# $Id$

require 5.008;
use warnings;
use strict;

use Data::Dumper;

use DNSCheck;

######################################################################

my $check = new DNSCheck({ interactive => 1 });

$check->smtp->test("mail.schlyter.se", "195.47.254.10", "jakob\@schlyter.se");
