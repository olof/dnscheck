#!/usr/bin/perl
#
# $Id$

require 5.8.0;
use warnings;
use strict;

use Data::Dumper;

use DNSCheck;

######################################################################

my $check = DNSCheck->new({ interactive => 1 });

my $nsid = $check->dns->query_nsid("62.119.93.254", "se", "IN", "SOA");
