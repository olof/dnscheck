#!/usr/bin/perl -sw
#
# $Id$

require 5.008;
use warnings;
use strict;

# use MockBootstrap 'main_object';
use MockResolver 'main_object';

use Test::More;

use_ok ('DNSCheck');
use Sys::Hostname;

######################################################################

my $dc = new_ok('DNSCheck' => [{ configdir => './t/config' }]);

SKIP: {
    skip "Failed to get an object to test", 4 unless defined($dc);
    ok(ref($dc)                          eq "DNSCheck");
    ok(ref($dc->config->get("net"))      eq "HASH");
    ok($dc->config->get("net")->{"smtp"} eq 1);
    ok($dc->config->get("hostname")      eq hostname);
    ok(ref($dc->dns)                     eq 'DNSCheck::Lookup::DNS');
    ok(ref($dc->logger)                  eq 'DNSCheck::Logger');
    ok($dc->dns->parent                  eq $dc);
    
    my $ztest = $dc->zone;
    ok($ztest);
    $dc->flush;
    my $ztest2 = $dc->zone;
    isnt($ztest, $ztest2, 'object got properly flushed');
    
    my $dc2 = new_ok('DNSCheck' => [{with_config_object => $dc->config}]);
    is($dc2->config, $dc->config, 'Config object correctly shared');
    
    $dc2->add_fake_glue('gurksallad.se', 'ns.nic.se');
    is(scalar(grep  {$_->{tag} =~ /^FAKEGLUE:/} @{$dc2->logger->{messages}}), 0, 'No FAKEGLUE message');
    ok($dc2->{faked}, 'Marked as faked');
    $dc2->add_fake_glue('gurksallad.se', 'ns17.nic.se');
    is(scalar(grep  {$_->{tag} =~ /^FAKEGLUE:NO_ADDRESS/} @{$dc2->logger->{messages}}), 1, 'No IPs for fake nameserver');
}

eval {
    DNSCheck::Test::Common->new;
};
like($@, qr|Creating test object without parent|, 'dies without parent');

done_testing();
