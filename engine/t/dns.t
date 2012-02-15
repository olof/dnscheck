#!/usr/bin/perl

use strict;
use warnings;

use Test::More;
use MockResolver 'dns', {multiple => 1};
# use MockBootstrap 'dns', {multiple => 1};

use_ok('DNSCheck');
my $dc = new_ok('DNSCheck');
my $dns = $dc->dns;
isa_ok($dns, 'DNSCheck::Lookup::DNS');

$dns->add_blacklist('127.0.0.1', 'iis.se', 'IN', 'SOA');
ok($dns->check_blacklist('127.0.0.1', 'iis.se', 'IN', 'SOA'), 'Query properly blacklisted');
$dns->clear_blacklist;
ok(!$dns->check_blacklist('127.0.0.1', 'iis.se', 'IN', 'SOA'), 'Blacklist properly cleared');

$dns->query_explicit("vbilen.se","IN","SOA","83.168.216.5",{dnssec=>1});
ok(scalar(grep {$_->[3] eq 'DNS:NO_EDNS'} @{$dc->logger->export})>0, 'NO_EDNS');
$dc->logger->clear;

$dns->query_explicit("vastralinnestaden.se","IN","SOA","193.13.74.204");
ok(scalar(grep {$_->[3] eq 'DNS:SOA_SERVFAIL'} @{$dc->logger->export})>0, 'SOA_SERVFAIL');
$dc->logger->clear;

done_testing();