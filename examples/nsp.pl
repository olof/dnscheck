#!/usr/bin/perl -l

use strict;
use warnings;
require 5.8.0;

use DNSCheck::NSP;
use Data::Dumper;

my $q = DNSCheck::NSP->new({interactive => 0, locale => "locale/sv.yaml"});

my $zone = $ARGV[0] || "iis.se";

my $packet = $q->{context}->dns->query_resolver($zone,"IN","SOA");

if (grep {ref $_ eq "Net::DNS::RR::SOA"} $packet->answer) {
    my ($name, $email) = $q->lookup($zone);
    if (defined($name)) {
        print "$name <$email>"
    } else {
        print "No data for domain."
    }
} else {
    print "That's not a domain."
}