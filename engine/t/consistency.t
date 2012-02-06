#!/usr/bin/perl

use Test::More;

# use MockBootstrap ('consistency', {multiple => 1});
use MockResolver ('consistency', {multiple => 1});

use_ok('DNSCheck');

my $dc = DNSCheck->new;
$dc->consistency->test('iis.se');

my %tags = map {$_->[3] => 1} @{$dc->logger->export};

ok($tags{'CONSISTENCY:SOA_DIGEST_CONSISTENT'});
ok($tags{'CONSISTENCY:SOA_SERIAL_CONSISTENT'});

$dc->logger->clear;
$dc->consistency->test('nic.se');

%tags = map {$_->[3] => 1} @{$dc->logger->export};

ok($tags{'CONSISTENCY:SOA_DIGEST_DIFFERENT'});
ok($tags{'CONSISTENCY:SOA_SERIAL_DIFFERENT'});


done_testing();