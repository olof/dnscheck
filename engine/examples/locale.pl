#!/usr/bin/perl
#
# $Id$

require 5.008;
use warnings;
use strict;

use DNSCheck;

######################################################################

my $check =
  DNSCheck->new({ interactive => 1, extras => { debug => 1 }, locale => "en" });

die "usage: $0 ip_address\n" unless ($ARGV[0]);

$check->asn->lookup($ARGV[0]);
