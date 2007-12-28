#!/usr/bin/perl
#
# $Id$

require 5.8.0;
use warnings;
use strict;

use Data::Dumper;

use DNSCheck::Engine;

######################################################################

my $engine = new DNSCheck::Engine(
    {
        db_host     => "127.0.0.1",
        db_port     => 13317,
        db_database => "dnscheckng",
        db_username => "dnscheckng",
        db_password => "engine",
        debug       => 0,
        verbose     => 1,
    }
);

$engine->process(10);
