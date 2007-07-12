#!/usr/bin/perl
#
# $Id$

require 5.8.0;
use warnings;
use strict;

use Data::Dumper;

use DNSCheck::Logger;
use DNSCheck::Lookup::DNS;

######################################################################

my $logger = new DNSCheck::Logger;
my $dns    = new DNSCheck::Lookup::DNS($logger);

my $domain = "schlyter.se";

my $parent = $dns->query_parent($domain, "IN", "NS");
my $child = $dns->query_child($domain, "IN", "NS");

$logger->dump();

print "********** PARENT **********\n";
print Dumper($parent->authority);

print "********** CHILD **********\n";
print Dumper($child->answer);
