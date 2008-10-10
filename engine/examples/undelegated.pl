#!/usr/bin/perl

use DNSCheck;

unless (@ARGV>1) {
    print "usage: $0 zone ns_ip [ns_ip ...]";
    exit(1);
}


my $dc = DNSCheck->new($DNSCheck::default->{config});
$dc->undelegated_zone(@ARGV);
$dc->logger->print;
