#!/usr/bin/perl -sw
#
# $Id$

require 5.008;
use warnings;
use strict;

use Test::More tests => 4;

use DNSCheck;

######################################################################

my $check = new DNSCheck;
ok(defined($check));
eval {    # Test for the bug fixed in r769
    $check->add_fake_glue('*.foo.test', 'ns.foo.test', '10.11.12.13');
    $check->zone->test('*.foo.test');
};
ok(!$@, "$@");

$check = DNSCheck->new;
ok(defined($check));
eval {    # Test for the bug fixed in r739
    $check->add_fake_glue('iis.se', 'ns.nic.se', 'gurkmos');
    $check->zone->test('iis.se');
};
ok(!$@, "$@");
