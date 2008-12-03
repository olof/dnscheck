#!/usr/bin/perl
#
# $Id: soa.pl 523 2008-10-23 14:19:24Z calle $

require 5.008;
use warnings;
use strict;

use DNSCheck;

######################################################################

my $check = new DNSCheck({ interactive => 1 });

# die "usage: $0 zone ns1-name ns1-ip ns2-name ns2-ip ..." unless (@ARGV > 1);

# Cheat to save typing
@ARGV = qw[undelegated.nl ns1.undelegated.nl 62.163.82.28 ns2.undelegated.nl 207.210.112.222]
 unless @ARGV>0;

my $domain = shift(@ARGV);
while (@ARGV) {
    my $name = shift @ARGV;
    my $ip   = shift @ARGV;

    $check->add_fake_glue($name, $ip);
}

$check->zone->test($domain);
