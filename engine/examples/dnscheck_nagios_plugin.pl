#!/usr/bin/perl

use warnings;
use strict;

use DNSCheck;
use Getopt::Long;

my $help;
my $debug;

GetOptions('help' => \$help, 'debug' => \$debug);

if ($help || @ARGV != 1) {
    print "usage: $0 zonename\n";
    exit(1);
}

my $zone = $ARGV[0];
my $check = DNSCheck->new;

$check->zone->test($zone);

my $critical = $check->logger->count_critical;
my $error = $check->logger->count_error;
my $warning = $check->logger->count_warning;
my $notice = $check->logger->count_notice;

$check->logger->print if $debug;

if ($critical > 0) {
    printf "Critical - %s may be unreachable\n", $zone;
    exit(2);
} elsif ($error > 0) {
    printf "Error - lookups for %s may have problems\n", $zone;
    exit(1);
} elsif ($warning > 0) {
    printf "OK - %s has %d warning%s\n", $zone, $warning, $warning==1?"s":"";
    exit(0);
} else {
    printf "OK - %s is clean\n", $zone;
    exit(0);
}
