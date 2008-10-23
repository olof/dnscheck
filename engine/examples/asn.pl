#!/usr/bin/perl
#
# $Id$

require 5.008;
use warnings;
use strict;

use DNSCheck;

######################################################################

my $check = DNSCheck->new;

die "syntax error" unless ($ARGV[0]);

print "$_\n" for @{ $check->asn->lookup($ARGV[0]) };
