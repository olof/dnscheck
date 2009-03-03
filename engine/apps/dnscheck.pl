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

require 5.008;
use warnings;
use strict;

use Getopt::Long;
use Pod::Usage;
use DNSCheck;

######################################################################

sub main {
    my $help  = 0;
    my $debug = 0;
    my $raw   = 0;

    my $locale = 'en';
    my (
        $configdir,  $sitedir,        $configfile, $siteconfigfile,
        $policyfile, $sitepolicyfile, $localefile, @nameservers,
        $what_test
    );

    GetOptions(
        'help|?'           => \$help,
        'raw'              => \$raw,
        'debug+'           => \$debug,
        'configdir=s'      => \$configdir,
        'sitedir=s'        => \$sitedir,
        'configfile=s'     => \$configfile,
        'siteconfigfile'   => \$siteconfigfile,
        'policyfile=s'     => \$policyfile,
        'sitepolicyfile=s' => \$sitepolicyfile,
        'localefile=s'     => \$localefile,
        'locale=s'         => \$locale,
        'nameserver=s'     => \@nameservers,
        'test=s'           => \$what_test,
    ) or pod2usage(2);
    pod2usage(1) if ($help);

    my $zone = shift @ARGV;

    unless ($zone) {
        pod2usage(2);
    }

    my $extras = {};
    $extras->{logging}->{interactive} = 1;
    $extras->{debug} = $debug;

    my $conf = {};
    $conf->{configdir}      = $configdir      if $configdir;
    $conf->{sitedir}        = $sitedir        if $sitedir;
    $conf->{configfile}     = $configfile     if $configfile;
    $conf->{siteconfigfile} = $siteconfigfile if $siteconfigfile;
    $conf->{policyfile}     = $policyfile     if $policyfile;
    $conf->{sitepolicyfile} = $sitepolicyfile if $sitepolicyfile;
    $conf->{localefile}     = $localefile     if $localefile;
    $conf->{locale} = ($raw ? undef : $locale);
    $conf->{extras} = $extras;

    my $check = new DNSCheck($conf);

    foreach my $ns (@nameservers) {
        my ($name, $ip) = split(m|/|, $ns);
        if ($ip) {
            $check->add_fake_glue($zone, $name, $ip);
        } else {
            $check->add_fake_glue($zone, $name);
        }
    }

    if ($what_test eq 'zone' or !$what_test) {
        $check->zone->test($zone)
    } elsif ($what_test eq 'connectivity') {
        $check->connectivity->test($zone)
    } elsif ($what_test eq 'consistency') {
        $check->consistency->test($zone)
    } elsif ($what_test eq 'dnssec') {
        $check->dnssec->test($zone)
    } elsif ($what_test eq 'delegation') {
        $check->delegation->test($zone)
    } elsif ($what_test eq 'soa') {
        $check->soa->test($zone)
    } else {
        print "Don't know how to perform a test of type $what_test on a zone.\n";
        exit(1);
    }
}

main();

__END__

=head1 NAME

dnscheck - DNSCheck Tool

=head1 SYNOPSIS

dnscheck [options] zone

Options:

 --help                brief help message
 --debug               enable debugging. use twice for dns packet dump.
 --raw                 raw log output, suitable for automatic processing
 --configdir           directory to look for config files in
 --sitedir             directory to look for site-specific config in
 --configfile          specify a configuration file
 --siteconfigfile      specify a file to read site config from
 --policyfile          specify a policy file
 --sitepolicyfile      specify a file to read site-specific policy from
 --localefile          specify a file to read locale from
 --locale              specify a locale to be used
 --nameserver          specify glue data as the name of a nameserver, or as
                       a name followed by a slash and its IP address. This
                       option can be given several times to specify multiple
                       servers or multiple IP addresses for the same name.
 --test=<test>         Specify which of the whole-zone tests to run. Currently
                       available are: zone, connectivity, consistency,
                       dnssec, delegation and soa.

 More specific options override less specific ones. If you, for example, give
 both C<--configdir> and C<--sitepolicyfile> all config will be read from files
 in the directory given in the first option, except for site-specific policy
 changes which will be read from the given file.

 The locales available for use with the C<--locale> switch at the time being
 are sv and en. en is the default.
