#!/usr/bin/perl

use strict;
use warnings;

use Test::More;
use MockResolver 'soa';
use File::Temp 'tempfile';

use_ok('DNSCheck');
my $dc = new_ok('DNSCheck' => [{ configfile => './t/config.yaml' }]);
$dc->soa->test('iis.se');

my $log = $dc->logger;

is($log->count_critical,0, 'No critical errors');
is($log->count_error,0, 'No errors');
is($log->count_warning,0, 'No warnings');
is($log->count_notice,0, 'No notices');
is($log->count_info,45, '51 informational messages');
is($log->count_debug,118, '112 debug messages');

my $msg = $log->export;
is(scalar(@$msg), 163, 'Correct number of entries dumped');

my $count = 0;
$count++ while($log->get_next_entry);
is($count, 163, 'Iterator saw all messages');

{
    local *STDERR;
    my ($fh, $filename) = tempfile();
    open STDERR, '>', $filename or die $!;
    $log->dump;
    STDERR->flush;
    my @lines = <$fh>;
    is(scalar(@lines),163, 'dump printed correct number of lines');
    close($fh);
    unlink($filename);
}

{
    local *STDOUT;
    my ($fh, $filename) = tempfile();
    open STDOUT, '>', $filename or die $!;
    $log->print;
    STDOUT->flush;
    my @lines = <$fh>;
    is(scalar(@lines),45, 'print printed correct number of lines');
    close($fh);
    unlink($filename);
}


done_testing();