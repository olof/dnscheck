#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';

use Test::More;
use MockBootstrap 'resolver', {multiple => 1};

use_ok('DNSCheck');

my $dc = new_ok('DNSCheck');
my $res = $dc->resolver;
isa_ok($res, 'DNSCheck::Lookup::Resolver');
isa_ok($res->resolver, 'Net::DNS::Resolver');
isa_ok($res->logger, 'DNSCheck::Logger');
is($res->dnssec,0, 'DNSSEC off');
is($res->errorstring,'unknown error or no error');
is($res->recursion,0, 'Recursion off');
is($res->cdflag,1, 'DNSSEC checking disabled');

my $rootdata = DNSCheck::Lookup::Resolver->get_preload_data;
is(ref($rootdata), 'HASH', 'We got a hasref back');
ok(defined($rootdata->{ips}{'a.root-servers.net.'}), 'We got IPs for at last one root server');

my $p = $res->recurse('www.lysator.liu.se', 'A');
isa_ok($p, 'Net::DNS::Packet');
ok(scalar(grep {$_->type eq 'A' and $_->address eq '130.236.254.11'} $p->answer)>0, 'Got the right answer');

$dc = DNSCheck->new;
$res = $dc->resolver;
$res->add_fake_glue('lysator.liu.se', 'ns-master.lysator.liu.se', '130.236.254.2');
$res->add_fake_glue('lysator.liu.se', 'ns-slave.lysator.liu.se', '130.236.254.4');
$res->add_fake_glue('lysator.liu.se', 'ns-slave-1.ifm.liu.se', '130.236.160.2');
$res->add_fake_glue('lysator.liu.se', 'ns-slave-2.ifm.liu.se', '2001:6b0:17:f180::1002');

my @tmp = $res->faked_zones;
is($tmp[0], 'lysator.liu.se', 'Zone is listed as faked');
@tmp = $res->faked_zone('lysator.liu.se');
is_deeply(\@tmp,
        [qw(ns-slave-2.ifm.liu.se ns-slave.lysator.liu.se ns-slave-1.ifm.liu.se ns-master.lysator.liu.se)],
        'Faked NS list looks OK');

#$p = $res->fake_packet('lysator.liu.se', 'www.lysator.liu.se', 'A');
#isa_ok($p, 'Net::DNS::Packet');

$p = $res->recurse('www.lysator.liu.se', 'A');
isa_ok($p, 'Net::DNS::Packet');
ok(scalar(grep {$_->type eq 'A' and $_->address eq '130.236.254.11'} $p->answer)>0, 'Got the right answer');

done_testing();