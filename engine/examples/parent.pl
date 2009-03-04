#!/usr/bin/perl
#
# $Id$

require 5.008;
use warnings;
use strict;

use DNSCheck;

######################################################################

my $check = DNSCheck->new({ interactive => 1, extras => { debug => 1 } });

die "usage: $0 name\n" unless ($ARGV[0]);

print $check->dns->find_parent($ARGV[0], "IN"), "\n";
