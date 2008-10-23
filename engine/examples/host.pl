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

$check->host->test("forastero.schlyter.se");
$check->host->test("t.schlyter.se");
$check->host->test("ns.schlyter.se");
$check->host->test("ns.kirei.se");
$check->host->test("ns1.kirei.se");
$check->host->test("ns_1.kirei.se");
$check->host->test("ns1-.kirei.se");
$check->host->test("1a.KIREI.se");
$check->host->test("ns4..kirei.se");
$check->host->test("ms.365-24.se");
