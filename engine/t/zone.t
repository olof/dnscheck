#!/usr/bin/perl
#
# $Id$

require 5.008;
use warnings;
use strict;

use Test::More tests => 11;

use DNSCheck;
use YAML;

######################################################################

my $dc;

eval {
    $dc = new DNSCheck(
        { configfile => './config.yaml', rootsource => '212.247.18.3' });
};

ok(!$@, $@);

SKIP: {
    skip "Failed to get an object to test", 4 unless defined($dc);
    ok(defined($dc->zone->test("power.fine")));
    my @res          = @{ $dc->logger->export };
    my $result_count = scalar(@res);
    ok(abs($result_count - 273) < 5, "Got $result_count lines from logger.");
    my $info_count = scalar(grep { $_->[2] eq 'INFO' } @res);
    ok(abs($info_count - 60) < 5, "$info_count INFO-level results.");
    ok($dc->logger->count_info == $info_count);
    my $notice_count = scalar(grep { $_->[2] eq 'NOTICE' } @res);
    ok(abs($notice_count - 4) < 3, "$notice_count NOTICE-level results.");
    ok($dc->logger->count_notice == $notice_count);
    my $warning_count = scalar(grep { $_->[2] eq 'WARNING' } @res);
    ok(abs($warning_count - 3) < 2, "$warning_count WARNING-level results.");
    ok($dc->logger->count_warning == $warning_count);
    my $debug_count = scalar(grep { $_->[2] eq 'DEBUG' } @res);
    ok(abs($debug_count - 203) < 5, "$debug_count DEBUG-level results.");
    ok($dc->logger->count_debug == $debug_count);
}
