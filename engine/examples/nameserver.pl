#!/usr/bin/perl
#
# $Id$

require 5.008;
use warnings;
use strict;

use Net::IP;
use DNSCheck;

######################################################################

my $check = DNSCheck->new({ interactive => 1, extras => {debug => 1} });

my ($zone, $server) = @ARGV;

die "horribly" unless (defined($zone) and defined($server));

if (Net::IP->new($server)) {
    $check->nameserver->test_by_ip($zone, $server);
} else {
    $check->nameserver->test($zone, $server);
}
