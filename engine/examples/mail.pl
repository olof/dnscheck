#!/usr/bin/perl
#
# $Id$

require 5.008;
use warnings;
use strict;

use DNSCheck;

######################################################################

my $check = new DNSCheck({ interactive => 1, extras => { debug => 1 } });

my @email = ("jakob\@kirei.se", "hostmaster\@n6.schlyter.se",
    "invalid-user\@schlyter.se");

foreach my $x (@email) {
    $check->mail->test($x);
}
