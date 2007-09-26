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

$check->smtp("mail.schlyter.se", "jakob\@schlyter.se");
$check->report();
