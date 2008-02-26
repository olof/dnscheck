#!/usr/bin/perl
#
# $Id$

require 5.8.0;
use warnings;
use strict;

use Getopt::Long;
use Pod::Usage;
use POSIX qw(setsid);
use DNSCheck::Engine;

######################################################################

my $config = "/etc/dnscheck.conf";

sub main {
    my $help      = 0;
    my $chunksize = 10;
    my $sleep     = 10;
    my $realtime  = 0;
    my $processes = 1;
    my $facility  = "daemon";
    my $debug     = 0;

    GetOptions(
        'help|?'      => \$help,
        'config=s'    => \$config,
        'chunksize=i' => \$chunksize,
        'sleep=i'     => \$sleep,
        'processes=i' => \$processes,
        'realtime'    => \$realtime,
        'debug'       => \$debug,
    ) or pod2usage(2);
    pod2usage(1) if ($help);

    if ($debug) {
        $facility = undef;
    }

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
            debug           => $debug,
            realtime        => $realtime,
        }
    );

    daemonize() if ($facility);

    while ($processes) {
        $processes--;

        my $pid = fork;
        next if $pid;

        $engine->daemon($chunksize, $sleep);
    }
}

sub daemonize {
    chdir '/' or die "Can't chdir to /: $!";
    open STDIN,  '/dev/null'   or die "Can't read /dev/null: $!";
    open STDOUT, '>>/dev/null' or die "Can't write to /dev/null: $!";
    open STDERR, '>>/dev/null' or die "Can't write to /dev/null: $!";
    defined(my $pid = fork) or die "Can't fork: $!";
    exit if $pid;
    setsid or die "Can't start a new session: $!";
    umask 0;
}

main();

__END__

=head1 NAME

dnscheck-qrun - DNSCheck Queue Runner

=head1 SYNOPSIS

dnscheck-qrun [options]

Options:

 --help                brief help message
 --chunksize=N         number of domains to test per run
 --config=FILE         database configuration file
 --facility=FACILITY   syslog facility
 --processes=N         number of processes to start
 --realtime            enable realtime processing
 --sleep=SECONDS       seconds between empty batches
