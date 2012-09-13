#!/usr/bin/perl

use Test::More;
use lib "t/lib";

# use MockBootstrap ('delegation', {multiple => 1});
use MockResolver ('delegation', {multiple => 1});

use_ok('DNSCheck');

my $dc = DNSCheck->new({configdir => './t/config'});

# Good zone
my ($errors, $testable) = $dc->delegation->test('iis.se');

is( $errors, 0, 'No errors');
ok( $testable, 'Zone is testable');

my %tags = map {$_->[3] => 1} @{$dc->logger->export};

foreach my $m (qw[GLUE_FOUND_AT_PARENT MATCHING_GLUE ]) {
    ok($tags{"DELEGATION:$m"}, "DELEGATION:$m");
}
$dc->logger->clear;

# Not good zone
($errors, $testable) = $dc->delegation->test('aflac.se');

is( $errors, 1, "$errors error(s)");
ok( !$testable, 'Zone is not testable');

%tags = map {$_->[3] => 1} @{$dc->logger->export};

foreach my $m (qw[NS_AT_PARENT NOT_FOUND_AT_CHILD BROKEN_BUT_FUNCTIONAL]) {
    ok($tags{"DELEGATION:$m"}, "DELEGATION:$m");
}
$dc->logger->clear;

# Other not good zone
($errors, $testable) = $dc->delegation->test('crystone.se');

ok( $errors == 2, "$errors error(s)");
ok( $testable, 'Zone is testable');

%tags = map {$_->[3] => 1} @{$dc->logger->export};

foreach my $m (qw[NS_AT_PARENT NS_AT_CHILD EXTRA_NS_PARENT NO_COMMON_NS_NAMES EXTRA_NS_CHILD NO_NS_IPV6 ]) {
    ok($tags{"DELEGATION:$m"}, "DELEGATION:$m");
}
$dc->logger->clear;

# Another one

($errors, $testable) = $dc->delegation->test('sig.se');
ok( $errors == 2, "$errors error(s)");
ok( $testable, 'sig.se is testable');

%tags = map {$_->[3] => 1} @{$dc->logger->export};

foreach my $m (qw[INCONSISTENT_GLUE]) {
    ok($tags{"DELEGATION:$m"}, "DELEGATION:$m");
}
$dc->logger->clear;

# And another
($errors, $testable) = $dc->delegation->test('uddevalla.se');

%tags = map {$_->[3] => 1} @{$dc->logger->export};

foreach my $m (qw[INZONE_NS_WITHOUT_GLUE]) {
    ok($tags{"DELEGATION:$m"}, "DELEGATION:$m");
}
$dc->logger->clear;


done_testing();
