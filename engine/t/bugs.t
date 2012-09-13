#!/usr/bin/perl -sw
#
# $Id$

require 5.008;
use warnings;
use strict;

use Test::More;

use DNSCheck;

######################################################################

my $check = new DNSCheck({configdir => './t/config'});
ok(defined($check));
eval {    # Test for the bug fixed in r769
    $check->add_fake_glue('*.foo.test', 'ns.foo.test', '10.11.12.13');
    $check->zone->test('*.foo.test');
};
ok(!$@, "$@");

$check = new DNSCheck({configdir => './t/config'});
ok(defined($check));
eval {    # Test for the bug fixed in r739
    $check->add_fake_glue('iis.se', 'ns.nic.se', 'gurkmos');
    $check->zone->test('iis.se');
};
ok(!$@, "$@");

is($check->config->get('smtp')->{hostname}, 'gurksallad', 'Right SMTP name from config');

done_testing;