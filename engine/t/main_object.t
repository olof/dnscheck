#!/usr/bin/perl -sw
#
# $Id$

require 5.008;
use warnings;
use strict;

use Test::More;

use_ok ('DNSCheck');
use Sys::Hostname;

######################################################################

my $dc = new_ok('DNSCheck' => [{ configfile => './t/config.yaml' }]);

SKIP: {
    skip "Failed to get an object to test", 4 unless defined($dc);
    ok(ref($dc)                          eq "DNSCheck");
    ok(ref($dc->config->get("net"))      eq "HASH");
    ok($dc->config->get("net")->{"smtp"} eq 1);
    ok($dc->config->get("hostname")      eq hostname);
    ok(ref($dc->dns)                     eq 'DNSCheck::Lookup::DNS');
    ok(ref($dc->logger)                  eq 'DNSCheck::Logger');
    ok($dc->dns->parent                  eq $dc);
    
    my $ztest = $dc->zone;
    ok($ztest);
    $dc->flush;
    my $ztest2 = $dc->zone;
    isnt($ztest, $ztest2, 'object got properly flushed');
}

done_testing();
