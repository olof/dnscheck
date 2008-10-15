#!/usr/bin/perl
#
# $Id$

require 5.8.0;
use warnings;
use strict;

use Net::IP;
use DNSCheck;

######################################################################

my $check = DNSCheck->new;

my ($zone, $server) = @ARGV;

die "horribly" unless (defined($zone) and defined($server));

if (Net::IP->new($server)) {
    $check->nameserver_by_ip($zone, $server);
} else {
    $check->nameserver($zone, $server);
}

$check->logger->dump;
