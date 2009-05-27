#!/usr/bin/perl -sw
#
# $Id$

require 5.008;
use warnings;
use strict;

use Test::More tests => 5;

use DNSCheck::Config;
use Sys::Hostname;

######################################################################

my $conf;

eval { $conf = new DNSCheck::Config(configfile => './config.yaml'); };

ok(!$@, $@);

SKIP: {
    skip "Failed to get an object to test", 4 unless defined($conf);
    ok(ref($conf)                  eq "DNSCheck::Config");
    ok(ref($conf->get("net"))      eq "HASH");
    ok($conf->get("net")->{"smtp"} eq 1);
    ok($conf->get("hostname")      eq hostname);
}
