#!/usr/bin/perl
#
# $Id$

require 5.008;
use warnings;
use strict;

use Test::More tests => 13;

use DNSCheck;

######################################################################

my $dc;

eval {
    $dc = new DNSCheck( {configfile => './config.yaml', rootsource => '212.247.18.3'} );
};

ok(!$@, $@);

SKIP: {
    skip "Failed to get an object to test", 4 unless defined($dc);
    ok(defined($dc->soa->test("power.fine")));
    my @msg = @{$dc->logger->{messages}};
    ok(scalar(@msg) == 98, "Total of ".scalar(@msg)." messages.");
    ok(grep {$_->{tag} eq 'SOA:MNAME_VALID'} @msg);
    ok(grep {$_->{tag} eq 'SOA:MNAME_PUBLIC'} @msg);
    ok(grep {$_->{tag} eq 'SOA:MNAME_IS_AUTH'} @msg);
    ok(grep {$_->{tag} eq 'MAIL:DELIVERY_IPV4_OK'} @msg);
    ok(grep {$_->{tag} eq 'SOA:RNAME_DELIVERABLE'} @msg);
    ok(grep {$_->{tag} eq 'SOA:TTL_OK'} @msg);
    ok(grep {$_->{tag} eq 'SOA:REFRESH_OK'} @msg);
    ok(grep {$_->{tag} eq 'SOA:RETRY_OK'} @msg);
    ok(grep {$_->{tag} eq 'SOA:EXPIRE_OK'} @msg);
    ok(grep {$_->{tag} eq 'SOA:MINIMUM_OK'} @msg);
}