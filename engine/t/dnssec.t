use Test::More;

use warnings;
use strict;

use 5.8.9;

use MockResolver 'dnssec';

BEGIN {use_ok('DNSCheck')};

my $dc = DNSCheck->new({configfile => './t/config.yaml'});

eval {$dc->dnssec->test('se.')};
ok(!$@, "test run without crash");

my @msg = @{$dc->logger->export};

my @check_for = qw[
    DS_FOUND
    CONSISTENT_EXTRA_PROCESSING
    DNSKEY_SIGNATURE_OK
    DNSKEY_NO_VALID_SIGNATURES
    SOA_SIGNATURE_OK
    SOA_NO_VALID_SIGNATURES
];

foreach my $m (@check_for) {
    ok(scalar(grep {$_->[3] eq "DNSSEC:$m"} @msg) > 0, "DNSSEC:$m found");
}

done_testing();