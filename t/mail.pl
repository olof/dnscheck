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

$check->mail("hostmaster\@kirei.se");
$check->mail("hostmaster\@n6.schlyter.se");

$check->report();
