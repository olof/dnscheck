#!/usr/bin/perl

use strict;
use warnings;

use Test::More;
use lib "t/lib";
use MockResolver 'soa';
use File::Temp 'tempfile';

use_ok( 'DNSCheck' );
my $dc = new_ok( 'DNSCheck' => [ { configdir => './t/config' } ] );
$dc->config->{disable}{mail}{test} = 0;
$dc->logger->set_filter( 'SOA:BEGIN', ['iis.se'], 'CRITICAL' );
$dc->soa->test( 'iis.se' );

my $log = $dc->logger;
isa_ok( $log,         'DNSCheck::Logger' );
isa_ok( $log->locale, 'DNSCheck::Locale' );

is( $log->count_critical, 1,   'Critical errors' );
is( $log->count_error,    0,   'Errors' );
is( $log->count_warning,  0,   'Warnings' );
is( $log->count_notice,   0,   'Notices' );
is( $log->count_info,     44,  'Informational messages' );
is( $log->count_debug,    118, 'Debug messages' );

my $msg = $log->export;
is( scalar( @$msg ), 163, 'Correct number of entries dumped' );

my $count = 0;
$count++ while ( $log->get_next_entry );
is( $count, 163, 'Iterator saw all messages' );

{
    local *STDERR;
    my ( $fh, $filename ) = tempfile();
    open STDERR, '>', $filename or die $!;
    $log->dump;
    STDERR->flush;
    my @lines = <$fh>;
    is( scalar( @lines ), 163, 'dump printed correct number of lines' );
    close( $fh );
    unlink( $filename );
}

{
    local *STDOUT;
    my ( $fh, $filename ) = tempfile();
    open STDOUT, '>', $filename or die $!;
    $log->print;
    STDOUT->flush;
    my @lines = <$fh>;
    is( scalar( @lines ), 45, 'print printed correct number of lines' );
    close( $fh );
    unlink( $filename );
}

$dc = new_ok( 'DNSCheck' => [ { configdir => './t/config', localefile => 'locale/en.yaml' } ] );
$dc->soa->test( 'iis.se' );
{
    local *STDOUT;
    my ( $fh, $filename ) = tempfile();
    open STDOUT, '>', $filename or die $!;
    $dc->logger->logname( 'gurksallad' );
    $dc->logger->print;
    STDOUT->flush;
    my @lines = <$fh>;
    is( scalar( @lines ), 19, 'print printed correct number of lines' );
    is( $lines[0], "  0.000: gurksallad INFO Begin testing SOA parameters for iis.se.\n", 'String translated OK' );
    close( $fh );
    unlink( $filename );
}

$dc = new_ok( 'DNSCheck' => [ { configdir => './t/config', localefile => 'locale/en.yaml' } ] );
$dc->config->put( 'loglevels', undef );
$dc->logger->logname( 'gurksallad' );
$dc->soa->test( 'iis.se' );
{
    local *STDERR;
    my ( $fh, $filename ) = tempfile();
    open STDERR, '>', $filename or die $!;
    $dc->logger->dump;
    STDERR->flush;
    my @lines = <$fh>;
    is( scalar( @lines ), 77, 'dump printed correct number of lines' );
    like( $lines[0], qr/gurksallad/, 'logname correct' );
    close( $fh );
    unlink( $filename );
}

{
    local *STDOUT;
    my ( $fh, $filename ) = tempfile();
    open STDOUT, '>', $filename or die $!;
    $dc = new_ok( 'DNSCheck' => [ { configfile => './t/config/config_filter.yaml', localefile => 'locale/sv.yaml' } ] );
    $dc->logger->logname( 'citronfromage' );
    is( $dc->logger->logname, 'citronfromage' );
    $dc->logger->{interactive} = 1;
    $dc->soa->test( 'iis.se' );
    STDOUT->flush;
    my @lines = <$fh>;
    is( scalar( @lines ), 19, 'interactive print printed correct number of lines' );
    like( $lines[0], qr/  0.(\d+): citronfromage WARNING B.rjar testa SOA-parametrar f.r iis.se./, 'String translated OK' );

    close( $fh );
    unlink( $filename );
}

done_testing();
