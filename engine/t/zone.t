#!/usr/bin/perl
#
# $Id$

require 5.008;
use warnings;
use strict;

use Test::More;

use MockResolver 'zone';
# use MockBootstrap 'zone';

use_ok 'DNSCheck';

######################################################################

my $dc = new_ok('DNSCheck' => [{ configfile => './t/config.yaml' }]);

if (!defined($dc)) {
    done_testing();
    exit;
}

ok(defined($dc->zone->test("iis.se")));
$dc->log_nameserver_times('iis.se');
my @res          = @{ $dc->logger->export };
my $result_count = scalar(@res);
ok(abs($result_count - 896) < 5,
    "Got $result_count lines from logger.");
my $info_count = scalar(grep { $_->[2] eq 'INFO' } @res);
ok(abs($info_count - 181) < 10, "$info_count INFO-level results.");
ok($dc->logger->count_info == $info_count);
my $notice_count = scalar(grep { $_->[2] eq 'NOTICE' } @res);
ok(abs($notice_count - 7) < 3, "$notice_count NOTICE-level results.");
ok($dc->logger->count_notice == $notice_count);
my $warning_count = scalar(grep { $_->[2] eq 'WARNING' } @res);
ok(abs($warning_count - 0) < 2,
    "$warning_count WARNING-level results.");
ok($dc->logger->count_warning == $warning_count);
my $debug_count = scalar(grep { $_->[2] eq 'DEBUG' } @res);
ok(abs($debug_count - 708) < 5, "$debug_count DEBUG-level results.");
ok($dc->logger->count_debug == $debug_count);

my %tag = map {$_->[3] => 1} @{$dc->logger->export};

ok($tag{'NSTIME:AVERAGE'}, 'Timing information is present');

$dc->logger->clear;
$dc->config->put('disable', {zone => {test => 1}});
$dc->zone->test('nic.se');
is_deeply($dc->logger->export, [], 'Test disabled');
$dc->logger->clear;

$dc->config->put('disable', {zone => {test => 0}});
$dc->config->get("net")->{ipv4} = undef;
$dc->config->get("net")->{ipv6} = undef;
$dc->config->get("net")->{smtp} = undef;
$dc->zone->test('nic.se');
is_deeply(
    [map {$_->[3]} @{$dc->logger->export}],
    [
    "ZONE:BEGIN",
    "DELEGATION:BEGIN",
    "DNS:GET_NS_AT_PARENT",
    "DNS:QUERY_PARENT",
    "DNS:QUERY_PARENT_NOCACHE",
    "DNS:FIND_PARENT",
    "DNS:FIND_PARENT_BEGIN",
    "DNS:NXDOMAIN",
    "DNS:NO_PARENT",
    "DELEGATION:NOT_FOUND_AT_PARENT",
    "DELEGATION:END",
    "ZONE:FATAL_DELEGATION",
    "ZONE:END",
    ],
    'IPv4, IPv6 and SMTP disabled');
$dc->logger->clear;

$dc->config->get('net')->{ipv6} = 1;
$dc->zone->test('iis.se');
is(scalar(@{$dc->logger->export}), 1114, 'IPv6-only tests');

$dc->config->get('net')->{ipv6} = 0;
$dc->config->get('net')->{ipv4} = 1;
$dc->zone->test('iis.se');
is(scalar(@{$dc->logger->export}), 2204, 'IPv4-only tests');

done_testing();