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
package DNSCheck::Config;

require 5.008;
use strict;
use warnings;

use File::Spec::Functions;
use Sys::Hostname;
use Carp;
use Cwd;
use List::Util qw(first);
use Storable qw(dclone);
use File::ShareDir 'dist_dir';
use Config::Any;

sub new {
    my $proto = shift;
    my $class = ref($proto) || $proto;
    my $self  = {};
    bless $self, $proto;

    my %arg = @_;
    
    my $default_config = _get_with_path(
        _catfile(dist_dir('DNSCheck'), 'config.yaml')
    );
    
    if ($arg{'configfile'} and not -r $arg{'configfile'}) {
        croak 'Configuration file ' . $arg{'configfile'} . ' not readable';
    }
    
    my $config = _get_with_path(
        $arg{'configfile'},
        _catfile($arg{'configdir'}, 'config.yaml'),
        '/etc/dnscheck/config.yaml',
    );
    
    my $default_policy = _get_with_path(
        _catfile(dist_dir('DNSCheck'), 'policy.yaml')
    );
    
    my $policy = _get_with_path(
        $arg{'policyfile'},
        _catfile($arg{'policydir'}, 'policy.yaml'),
        '/etc/dnscheck/policy.yaml',
    );
    
    my $locale;
    if ($arg{'localefile'}) {
        $locale = _get_with_path($arg{'localefile'});
    } else {
        my $l = $arg{'locale'} || 'en';
        $locale = _get_with_path(_catfile(dist_dir('DNSCheck'), $l . '.yaml'));
    }
    
    _hashrefcopy($self, $default_config);
    _hashrefcopy($self, $config) if defined($config);
    _hashrefcopy($self, $default_policy);
    _hashrefcopy($self, $policy) if defined($policy);

    $self->{locale} = $locale;

    _hashrefcopy($self, $arg{extras})
      if (defined($arg{extras}) && (ref($arg{extras}) eq 'HASH'));

    # Special cases
    $self->{'hostname'} ||= hostname;
    $self->{'logging'}{'interactive'} = 1 if $arg{'interactive'};

    return $self;
}

sub get {
    my $self = shift;
    my ($key) = @_;

    my $res = $self->{$key};
    if (ref($res)) {
        $res = dclone($res);
    }

    return $res;
}

sub put {
    my $self = shift;

    my ($key, $value) = @_;
    $self->{$key} = $value;

    return $value;
}

sub should_run {
    my $self = shift;

    my (undef, undef, undef, $subroutine) = caller(1);

    if ($self->get("disable") and $subroutine =~ /^DNSCheck::Test::(.*)$/) {
        my ($module, $test) = map { lc($_) } split('::', $1, 2);

        return !$self->get("disable")->{$module}{$test};
    } else {
        return 1;
    }
}

###
### Non-public functions below here
###

sub _catfile {
    my @tmp = grep {$_} @_;
    
    return catfile(@tmp);
}

sub _get_with_path {
    my @files = grep {$_} @_;

    my $cfg = Config::Any->load_files({
        files => \@files,
        use_ext => 1,
    });

    my ($c) = values %{$cfg->[0]};
    return $c;
}

sub _hashrefcopy {
    my ($target, $source) = @_;

    foreach my $pkey (keys %{$source}) {
        $target->{$pkey} = {} unless defined($target->{$pkey});

        if (ref($source->{$pkey}) eq 'HASH') {

    # Hash slice assignment to copy all keys under the $pkey top-level key.
    # We don't just copy the entire hash since a site file may have changed only
    # some of the keys in it.
            @{ $target->{$pkey} }{ keys %{ $source->{$pkey} } } =
              values %{ $source->{$pkey} };
        } else {
            $target->{$pkey} = $source->{$pkey};
        }
    }
}

1;

=head1 NAME

DNSCheck::Config - Read config files and make their contents available to
other modules.

=head1 DESCRIPTION

Reads any config files, specified and/or default ones, stores their contents
and provides methods that other modules can use to fetch them.

There are two distinct classes of configuration information, that reside in
separate files. There is I<configuration>, which modifies how things run. This
is, for example, network timeouts, database connection information, file paths
and such. In addition to this there is I<policy>, which specifies things about
the tests that get run. Most importantly, the policy information specifies the
reported severity level of various test failures.

By default, C<DNSCheck::Config> will look for four different files:
F<policy.yaml>, F<config.yaml>, F<site_policy.yaml> and F<site_config.yaml>.
Only the first two exist by default. If the second two exist, they will
override values in their respective non-site file. Local changes should go in
the site files, since the default files will get overwritten when a new
DNSCheck version is installed.

These four files will be looked for in a number of places: a config directory,
the current working directory (as determined by the Cwd module) and the
directory where the running script file is stored (as determined by the
FindBin module). By default, the config directory is F<share/dnscheck> under
the root directory for the Perl installation. This can be changed via the
C<configdir> (for F<config.yaml> and F<policy.yaml>) and C<sitedir> (for
F<site_config.yalm> and F<site_policy.yaml>) parameters.

The default lookup of a file is disregarded if the parameter giving the full
path to that file is used.

There is no protection against having the same keys in the configuration and
policy files. The configuration/policy distinction is entirely for human use,
and if they want to put everything in the same bucket they're perfectly
welcome to do so.

=head1 METHODS

=over

=item ->new(parameter => $value)

The C<new> method creates a new C<DNSCheck::Config> object. It takes named
parameters in the perl/Tk style (but without the initial dashes). 

The available parameters are these:

=over

=item configdir

The path to the directory in which the module should look for configuration
and policy files.

=item sitedir

The path to the directory where the site configuration files are. By default the same as F<configdir>.

=item configfile

The full path to the configuration file.

=item siteconfigfile

The full path to the site configuration file.

=item policyfile

The full path to the policy file.

=item sitepolicyfile

The full path to the site policy file.

=item locale

The locale to be used for messages. This is supposed to be only a string with
the locale, for example "en" or "sv". The actual filename will be figured out
from that.

=item localefile

The full path to the actual YAML file holding the locale information to be used.

=item interactive

If this key is a true value, the logger object will be set to print entries to
stdout as they are added, rather than store them for future use.

=item extras

A hashref with random stuff that'll be copied to the Config object.

=back

=item ->get($key)

Simply returns whatever got read from the configuration or policy files under
the given key.

=item ->put($key, $value)

Stores the given value for the given key.

=item ->should_run()

Returns true or false depending on if the calling method is disabled in the 
configuration or not. The default is to let it run.

=back

=cut
