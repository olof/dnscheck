#!/usr/bin/perl
#
# $Id$

require 5.008;
use warnings;
use strict;

use Test::More;

use MockResolver 'zone';
use_ok 'DNSCheck';

######################################################################

my $dc = new_ok('DNSCheck' => [{ configfile => './config.yaml' }]);

if (!defined($dc)) {
    done_testing();
    exit;
}

ok(defined($dc->zone->test("iis.se")));
$dc->log_nameserver_times('iis.se');
my @res          = @{ $dc->logger->export };
my $result_count = scalar(@res);
ok(abs($result_count - 1312) < 5,
    "Got $result_count lines from logger.");
my $info_count = scalar(grep { $_->[2] eq 'INFO' } @res);
ok(abs($info_count - 260) < 10, "$info_count INFO-level results.");
ok($dc->logger->count_info == $info_count);
my $notice_count = scalar(grep { $_->[2] eq 'NOTICE' } @res);
ok(abs($notice_count - 10) < 3, "$notice_count NOTICE-level results.");
ok($dc->logger->count_notice == $notice_count);
my $warning_count = scalar(grep { $_->[2] eq 'WARNING' } @res);
ok(abs($warning_count - 0) < 2,
    "$warning_count WARNING-level results.");
ok($dc->logger->count_warning == $warning_count);
my $debug_count = scalar(grep { $_->[2] eq 'DEBUG' } @res);
ok(abs($debug_count - 1033) < 5, "$debug_count DEBUG-level results.");
ok($dc->logger->count_debug == $debug_count);

my %tag = map {$_->[3] => 1} @{$dc->logger->export};

ok($tag{'NSTIME:AVERAGE'}, 'Timing information is present');

done_testing();