#!/usr/bin/perl
#
# $Id$

require 5.008;
use warnings;
use strict;

use Data::Dumper;

use DNSCheck;

######################################################################

my $logger = DNSCheck->new->logger;

$logger->add("level1", "tag1", 1, 2, 3);
$logger->add("level2", "tag2", 4, 5, 6);

my $log = $logger->export();

foreach my $line (@{$log}) {
    print Dumper($line);
    print "---\n";
}
