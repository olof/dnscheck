#!/usr/bin/perl -sw
#
# $Id$

require 5.8.0;
use warnings;
use strict;

use Test::More tests => 4;

use DNSCheck::Logger;
use DNSCheck::Lookup::DNS;

######################################################################

my $logger = new DNSCheck::Logger();
my $dns = new DNSCheck::Lookup::DNS($logger);

######################################################################

ok($dns->find_parent("iis.se", "IN") eq "se");
ok($dns->find_parent("narnia.pp.se", "IN") eq "se");
ok($dns->find_parent("example.com", "IN") eq "com");
ok($dns->find_parent("se", "IN") eq ".");
