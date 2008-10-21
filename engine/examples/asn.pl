#!/usr/bin/perl
#
# $Id$

require 5.8.0;
use warnings;
use strict;

use DNSCheck;

######################################################################

my $check = DNSCheck->new;

die "syntax error" unless ($ARGV[0]);

print "$_\n" for @{ $check->asn->lookup($ARGV[0]) };
