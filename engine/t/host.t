#!/usr/bin/perl -sw
#
# $Id$

require 5.008;
use warnings;
use strict;

use Test::More;

use DNSCheck;

######################################################################

my $ht;

eval { $ht = new DNSCheck({ configdir => './t/config' })->host; };

ok(!$@, "Have an object $@");

SKIP: {
    skip "Failed to get an object to test", 4 unless defined($ht);
    ok($ht->host_syntax('foo.bar.com') == 0,    'Good name');
    ok($ht->host_syntax('xxx.' x 64) > 0,       'Name too long overall');
    ok($ht->host_syntax('x' x 64 . '.com') > 0, 'Label too long');
    ok($ht->host_syntax('foo.-bar.com') > 0, 'Label may not start with dash');
    ok($ht->host_syntax('foo.bar-.com') > 0, 'Label may not end with dash');
    ok($ht->host_syntax('foo.b------r.com') == 0, 'Label may contain dashes');
    ok($ht->host_syntax('foo.bar.4711') > 0,
        'Top-level may not be all-numeric');
    ok($ht->host_syntax('a.bar.com') == 0, 'One-octet labels are allowed');
    ok($ht->host_syntax('foo..com') > 0,   'Label must not be empty');
    is($ht->host_syntax(''), 0, 'There must be labels');
    is($ht->host_syntax(undef), 0, 'Test string must be defined');
}

done_testing;