#!/usr/bin/perl
#
# $Id$

require 5.008;
use warnings;
use strict;

use DNSCheck;

######################################################################

my $check = new DNSCheck({ interactive => 1, extras => { debug => 1 } });

$check->smtp->test("mail.schlyter.se", "195.47.254.10", "jakob\@schlyter.se");
