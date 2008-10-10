#!/usr/bin/perl
#
# $Id$
#
# Copyright (c) 2007 .SE (The Internet Infrastructure Foundation).
#                    All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
# IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY
# DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
# GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER
# IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
# OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN
# IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
######################################################################

require 5.8.0;
use warnings;
use strict;

use Getopt::Long;
use Pod::Usage;
use POSIX qw(setsid);
use DNSCheck::Engine;

my $CONFIG_DIR = '@@CONFIG_DIR@@';
my $POLICY_DIR = '@@POLICY_DIR@@';

######################################################################

sub main {
    my $help         = 0;
    my $config_file  = $CONFIG_DIR . "/config.yaml";
    my $policy_file  = $POLICY_DIR . "/policy.yaml";
    my $sleep        = 10;
    my $chunksize    = 10;
    my $processes    = 1;
    my $facility     = "daemon";
    my $realtime     = 0;
    my $debug        = 0;
    my $disable_ipv4 = undef;
    my $disable_ipv6 = undef;
    my $disable_smtp = undef;

    GetOptions(
        'help|?'       => \$help,
        'config=s'     => \$config_file,
        'policy=s'     => \$policy_file,
        'sleep=i'      => \$sleep,
        'chunksize=i'  => \$chunksize,
        'processes=i'  => \$processes,
        'facility=s'   => \$facility,
        'realtime'     => \$realtime,
        'debug'        => \$debug,
        'disable-ipv4' => \$disable_ipv4,
        'disable-ipv6' => \$disable_ipv6,
        'disable-smtp' => \$disable_smtp,
    ) or pod2usage(2);
    pod2usage(1) if ($help);

    # read configuration
    my $config;
    if (-r $config_file) {
        my ($hashref, $arrayref, $string) = LoadFile($config_file);
        $config = $hashref;
    } else {
        die "Failed to read config from $config_file";
    }

    # read policy
    my $policy;
    if (-r $policy_file) {
        my ($hashref, $arrayref, $string) = LoadFile($policy_file);
        $config->{policy} = $hashref;
    } else {
        die "Failed to read policy from $policy_file";
    }

    # turn of syslog if we try to debug
    if ($debug) {
        $facility = undef;
    }

    # realtime process handles only priority 5-10
    # non-realtime process handles only priority 0-4
    if ($realtime) {
        $config->{engine}->{prio_low}  = 5;
        $config->{engine}->{prio_high} = 10;
    } else {
        $config->{engine}->{prio_low}  = 0;
        $config->{engine}->{prio_high} = 4;
    }

    # let command line parameters override configuration file
    $config->{dns}->{ipv4}               = 0          if ($disable_ipv4);
    $config->{dns}->{ipv6}               = 0          if ($disable_ipv6);
    $config->{smtp}->{enable}            = 0          if ($disable_smtp);
    $config->{engine}->{syslog_facility} = $facility  if ($facility);
    $config->{engine}->{chunksize}       = $chunksize if ($chunksize);
    $config->{engine}->{processes}       = $processes if ($processes);

    # daemonize only if we have syslog
    daemonize() if ($facility);

    my $n = $processes;
    while ($n) {
        $n--;

        my $pid = fork;

        if ($pid) {
            print STDERR "Engine $pid forked\n" if ($debug);
            next;
        }

        my $engine = new DNSCheck::Engine($config);
        $engine->daemon($chunksize, $sleep);
    }

    print STDERR "Forked $processes engine processes\n" if ($debug);
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
 --config=FILE         configuration file
 --policy=FILE         policy file
 --sleep=SECONDS       seconds between empty batches
 --chunksize=N         number of domains to test per run
 --processes=N         number of processes to start
 --realtime            process realtime priorities only
 --facility=FACILITY   syslog facility
 --debug               debug
 --disable-ipv4        disable IPv4 transport
 --disable-ipv6        disable IPv6 transport
 --disable-smtp        disable SMTP test, suitable if port 25 is filtered
