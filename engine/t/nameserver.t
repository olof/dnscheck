#!/usr/bin/perl

use strict;
use warnings;

use Test::More;
use MockResolver 'nameserver', {multiple => 1};

use_ok('DNSCheck');
my $dc = new_ok('DNSCheck');
my $ns = $dc->nameserver;
isa_ok($ns, 'DNSCheck::Test::Nameserver');

is($ns->test_by_ip('nic.se', '2a00:801:f0:53::53'), 0);

done_testing();