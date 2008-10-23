#!/usr/bin/perl -sw
#
# $Id: find_parent.t 249 2008-03-03 15:48:42Z jakob $

require 5.008;
use warnings;
use strict;

use Test::More tests => 3;

use DNSCheck;

######################################################################

my $dc;

eval {
    $dc = new DNSCheck( {configfile => './config.yaml'} );
};

ok(!$@, $@);

SKIP: {
    skip "Failed to get an object to test", 4 unless defined($dc);
    ok(defined($dc->zone->test("iis.se")));
    my $result_count = scalar(@{$dc->logger->export});
    # If we don't get at least 100 lines when testing iis.se, *something* is wonky
    ok( $result_count > 100, "Got $result_count lines from logger.");
}