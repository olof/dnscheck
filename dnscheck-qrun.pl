#!/usr/bin/perl
#
# $Id$

require 5.8.0;
use warnings;
use strict;

use Getopt::Long;
use Pod::Usage;
use DNSCheck::Engine;

######################################################################

my $config = "/etc/dnscheck.conf";

sub main {
    my $help      = 0;
    my $chunksize = 10;
    my $sleep     = 30;
    my $facility  = "daemon";

    GetOptions(
        'help|?'      => \$help,
        'config=s'    => \$config,
        'chunksize=i' => \$chunksize,
    ) or pod2usage(2);
    pod2usage(1) if ($help);

    my $engine = new DNSCheck::Engine(
        {
            syslog_facility => $facility,
            db_config       => $config,
            udp_timeout     => 2,
            tcp_timeout     => 5,
            retry           => 3,
            retrans         => 2,
            disable_ipv4    => 0,
            disable_ipv6    => 0,
            ignore_debug    => 1,
        }
    );

    while (1) {
        my $n = $engine->process($chunksize);
        sleep($sleep) unless ($n);
    }
}

main();

__END__

=head1 NAME

dnscheck-qrun - DNSCheck Queue Runner

=head1 SYNOPSIS

dnscheck-qrun [options]

Options:

 --help                brief help message
 --config=FILE         database configuration file
 --chunksize=N         number of domains to test per run
 --facility=FACILITY   syslog facility
 --sleep=SECONDS       seconds between empty batches
