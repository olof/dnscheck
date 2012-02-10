#!/usr/bin/perl -sw
#
# $Id$

require 5.008;
use warnings;
use strict;

use Test::More tests => 4;
use MockResolver 'asn';
use DNSCheck;

######################################################################

my $check = new DNSCheck;

######################################################################

ok(join(",", @{ $check->asn->lookup("195.47.254.0") }) eq "47698");
ok(join(",", @{ $check->asn->lookup("192.71.220.0") }) eq "1257");

my $asn = $check->asn;
is($asn->parent,$check);
$asn->flush;
ok(!$asn->{asn});
