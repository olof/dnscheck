#!/usr/bin/perl

use strict;
use warnings;

use Test::More;
use MockResolver 'nameserver', {multiple => 1};
# use MockBootstrap 'nameserver', {multiple => 1};

use_ok('DNSCheck');
my $dc = new_ok('DNSCheck' => [{configdir => './t/config'}]);
my $ns = $dc->nameserver;
isa_ok($ns, 'DNSCheck::Test::Nameserver');

sub has {
    my ($zone, $server, $errors, @tags) = @_;

    is($ns->test_by_ip($zone, $server), $errors);
    foreach my $tag (@tags) {
        ok(scalar(grep {$_->[3] eq $tag} @{$dc->logger->export}) > 0, "Has $tag");
    }
    $dc->logger->clear;
}

is($ns->test_by_ip('nic.se', '2a00:801:f0:53::53'), 0);
$dc->logger->clear;

has('zzinazz.se', '91.198.169.5', 0,
    'NAMESERVER:LEGACY_ID',
    'NAMESERVER:AUTH',
    'NAMESERVER:NOT_RECURSIVE',
    'NAMESERVER:UDP_OK',
    'NAMESERVER:TCP_OK',
);

has('xyng.se', '82.119.225.103', 1, 'NAMESERVER:NOT_AUTH');

done_testing();
