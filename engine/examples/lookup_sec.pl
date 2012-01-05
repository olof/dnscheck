#!/usr/bin/perl
#
# $Id: zone.pl 715 2009-03-04 07:59:46Z calle $

require 5.008;
use warnings;
use strict;

use DNSCheck;

######################################################################

my $r = DNSCheck->new({ interactive => 1, extras => { debug => 2 } })->resolver;
$r->do_validation(1);

my ($name, $type, $class) = @ARGV;

$class ||= 'IN';
$type  ||= 'A';

die "usage: $0 name [type [class]]\n" unless $name;

my $p = $r->recurse($name, $type, $class);

if ($p) {
    $p->print;
} else {
    print "No answer.\n";
}
