#!/usr/bin/env perl

use 5.8.9;
use strict;
use warnings;

use Test::More;
use lib "t/lib";

use MockResolver 'connectivity';
# use MockBootstrap 'connectivity';

use_ok('DNSCheck');

my $dc = new_ok('DNSCheck' => [{configdir => './t/config'}]);
my $log = $dc->logger;
my $c = $dc->connectivity;

sub has {
    my ($zone, $errors, @tags) = @_;

    is($c->test($zone), $errors, 'expected error count');
    foreach my $tag (@tags) {
        ok(scalar(grep {$_->[3] eq $tag} @{$dc->logger->export}) > 0, "Has $tag");
    }
    $dc->logger->clear;
}

isa_ok($log, 'DNSCheck::Logger');
isa_ok($c, 'DNSCheck::Test::Connectivity');

has('iis.se', 0, qw[
    CONNECTIVITY:BEGIN
    CONNECTIVITY:ANNOUNCED_BY_ASN
    CONNECTIVITY:ASN_LIST
    CONNECTIVITY:ASN_COUNT_OK
    CONNECTIVITY:V6_ANNOUNCED_BY_ASN
    CONNECTIVITY:V6_ASN_LIST
    CONNECTIVITY:V6_TOO_FEW_ASN
    CONNECTIVITY:END
]);

has('oknackhe.se', 0, qw[
    CONNECTIVITY:ANNOUNCED_BY_ASN
    CONNECTIVITY:NOT_ANNOUNCED
    CONNECTIVITY:ASN_LIST
    CONNECTIVITY:TOO_FEW_ASN
    CONNECTIVITY:V6_ASN_LIST
    CONNECTIVITY:V6_TOO_FEW_ASN
]);

has('waytowork.se', 0, qw[CONNECTIVITY:V6_ASN_COUNT_OK]);

done_testing;
