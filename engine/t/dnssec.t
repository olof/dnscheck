use Test::More;
use lib "t/lib";

use warnings;
use strict;

use 5.8.9;

use MockResolver 'dnssec', {multiple => 1};
# use MockBootstrap 'dnssec', {multiple => 1};

BEGIN{
    *CORE::GLOBAL::time = sub {
        return 1347539258;
    };
};

BEGIN {use_ok('DNSCheck')};

my $dc = DNSCheck->new({configdir => './t/config'});

eval {$dc->dnssec->test('se.')};
ok(!$@, "test run without crash");

my @msg = @{$dc->logger->export};

my @check_for = qw[
    NO_DS_FOUND
    CONSISTENT_EXTRA_PROCESSING
    DNSKEY_SIGNATURE_OK
    DNSKEY_NO_VALID_SIGNATURES
    SOA_SIGNATURE_OK
    SOA_VALID_SIGNATURES
];

foreach my $m (@check_for) {
    ok(scalar(grep {$_->[3] eq "DNSSEC:$m"} @msg) > 0, "DNSSEC:$m found");
}

done_testing();
