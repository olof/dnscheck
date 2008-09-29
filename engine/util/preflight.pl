#!/usr/bin/perl -l

use DNSCheck::Logger;
use DNSCheck::Lookup::DNS;
use Data::Dumper;

my $logger = DNSCheck::Logger->new();
my $dns    = DNSCheck::Lookup::DNS->new($logger);

if ($dns->preflight_check($ARGV[0])) {
    print "TRUE";
} else {
    print "FALSE";
}
