#!/usr/bin/perl

use strict;
use warnings;

use Test::More;
use File::Temp 'tempfile';

my ($fh, $filename) = tempfile();

use_ok('DNSCheck');
my $dc = new_ok('DNSCheck' => [{localefile => 'locale/en.yaml'}]);
my $loc = $dc->logger->locale;
isa_ok($loc, 'DNSCheck::Locale');

is($loc->expand('ZONE:BEGIN','iis.se',17),'Begin testing zone iis.se with version 17.');

{
    local *STDERR;
    open STDERR, '>', $filename or die $!;
    $loc->expand('ZONE:BEGIN', 1, 2, 3, 4, 5, 6);
    my $tmpstr = join('',<$fh>);
    like($tmpstr, qr/invalid number of arguments supplied for ZONE:BEGIN/);
    unlink $filename or die $!;
}

my $dc2 = new_ok('DNSCheck');
is($dc2->logger->locale->expand('ZONE:BEGIN'),'[MISSING LOCALE] ZONE:BEGIN ');

done_testing();