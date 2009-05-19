#!/usr/bin/perl
#
# $Id$

require 5.008;
use warnings;
use strict;

use Test::More tests => 11;

use DNSCheck;

######################################################################

my $dc;

eval {
    $dc = new DNSCheck( {configfile => './config.yaml', rootsource => '212.247.18.3'} );
};

ok(!$@, $@);

SKIP: {
    skip "Failed to get an object to test", 4 unless defined($dc);
    ok(defined($dc->zone->test("power.fine")));
    my @res = @{$dc->logger->export};
    my $result_count = scalar(@res);
    ok( $result_count == 303, "Got $result_count lines from logger.");
    my $info_count = scalar(grep {$_->[2] eq 'INFO'} @res);
    ok( $info_count == 65, "$info_count INFO-level results.");
    ok($dc->logger->count_info == $info_count);
    my $notice_count = scalar(grep {$_->[2] eq 'NOTICE'} @res);
    ok( $notice_count == 4, "$notice_count NOTICE-level results.");
    ok($dc->logger->count_notice == $notice_count);
    my $warning_count = scalar(grep {$_->[2] eq 'WARNING'} @res);
    ok( $warning_count == 0, "$warning_count WARNING-level results.");
    ok($dc->logger->count_warning == $warning_count);
    my $debug_count = scalar(grep {$_->[2] eq 'DEBUG'} @res);
    ok( $debug_count == 232, "$debug_count DEBUG-level results.");
    ok($dc->logger->count_debug == $debug_count);
}