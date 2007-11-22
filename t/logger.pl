#!/usr/bin/perl
#
# $Id$

require 5.8.0;
use warnings;
use strict;

use Data::Dumper;

use DNSCheck::Logger;

######################################################################

my $logger = new DNSCheck::Logger;

$logger->add("foo", 1, 2, 3);
$logger->add("bar", 4, 5, 6);

my @log = $logger->export();

foreach my $line (@log) {
	print $line, "\n";
}
