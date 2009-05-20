#!/usr/bin/perl -sw
#
# $Id: find_parent.t 249 2008-03-03 15:48:42Z jakob $

require 5.008;
use warnings;
use strict;

use Test::More tests => 2;

use DNSCheck;

######################################################################

my $check = new DNSCheck;

######################################################################

ok(join(",", @{ $check->asn->lookup("195.47.254.0") }) eq "29344");
ok(join(",", @{ $check->asn->lookup("192.71.220.0") }) eq "1257");
