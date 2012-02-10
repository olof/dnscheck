#!/usr/bin/perl

use strict;
use warnings;

use Test::More;
use MockResolver 'dns', {multiple => 1};

use_ok('DNSCheck');
my $dc = new_ok('DNSCheck');
my $dns = $dc->dns;
isa_ok($dns, 'DNSCheck::Lookup::DNS');

$dns->add_blacklist('127.0.0.1', 'iis.se', 'IN', 'SOA');
ok($dns->check_blacklist('127.0.0.1', 'iis.se', 'IN', 'SOA'), 'Query properly blacklisted');
$dns->clear_blacklist;
ok(!$dns->check_blacklist('127.0.0.1', 'iis.se', 'IN', 'SOA'), 'Blacklist properly cleared');


done_testing();