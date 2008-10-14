#!/usr/bin/perl -l

use DNSCheck;

my $dc  = DNSCheck->new;
my $dns = $dc->dns;

if ($dns->preflight_check($ARGV[0])) {
    print "TRUE";
} else {
    print "FALSE";
}
