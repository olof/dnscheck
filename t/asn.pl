#!/usr/bin/perl
#
# $Id$

require 5.8.0;
use warnings;
use strict;

use Data::Dumper;

use DNSCheck::Logger;
use DNSCheck::Lookup::DNS;
use DNSCheck::Lookup::ASN;

######################################################################

my $logger = new DNSCheck::Logger;
my $dns    = new DNSCheck::Lookup::DNS($logger);
my $asn    = new DNSCheck::Lookup::ASN($logger, $dns);

$asn->lookup("195.47.254.10");
$asn->lookup("195.47.254.10");

$logger->dump();
