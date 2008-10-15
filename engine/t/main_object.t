#!/usr/bin/perl -sw
#
# $Id: find_parent.t 249 2008-03-03 15:48:42Z jakob $

require 5.8.0;
use warnings;
use strict;

use Test::More tests => 9;

use DNSCheck;
use Sys::Hostname;

######################################################################

my $dc;

eval {
    $dc = new DNSCheck( {configfile => './config.yaml'} );
};

ok(!$@, $@);

SKIP: {
    skip "Failed to get an object to test", 4 unless defined($dc);
    ok(ref($dc) eq "DNSCheck");
    ok(ref($dc->config->get("net")) eq "HASH");
    ok($dc->config->get("net")->{"smtp"} eq 1);
    ok($dc->config->get("hostname") eq hostname);
    ok(ref($dc->dns) eq 'DNSCheck::Lookup::DNS');
    ok(ref($dc->context) eq 'DNSCheck::Context');
    ok(ref($dc->logger) eq 'DNSCheck::Logger');
    ok($dc->dns->parent eq $dc);
}