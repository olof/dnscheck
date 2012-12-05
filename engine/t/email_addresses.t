#!/usr/bin/perl -sw
#
# $Id$

require 5.008;
use warnings;
use strict;
use lib "t/lib";

use Test::More;
use MockResolver 'email_addresses';
use DNSCheck;

######################################################################

my $check = new DNSCheck({configdir => './t/config', policydir => './t/config' });
$check->config->{disable}{mail}{test} = 0;

######################################################################

ok($check->mail->test("postmaster\@iis.se") == 0);
ok(
    $check->mail->test(
        "postmaster\@6f3899904701b0ce2835d82493c0212babf875c7.se") == 1
);
ok($check->mail->test("postmasteriis.se") == 1);

done_testing;