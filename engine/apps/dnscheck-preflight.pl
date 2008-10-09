#!/usr/bin/perl -l

use DNSCheck;
use Config;

my $dc = DNSCheck->new($DNSCheck::default->{config});
my $dns = $dc->{context}->dns;

if ($dns->preflight_check($ARGV[0])) {
    print "TRUE";
} else {
    print "FALSE";
}