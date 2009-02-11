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

package DNSCheck::Logger;

require 5.008;
use warnings;
use strict;

our $SVN_VERSION = '$Revision$';

use Time::HiRes qw(time);
use DNSCheck::Locale;
use Data::Dumper;

######################################################################

sub new {
    my $proto = shift;
    my $class = ref($proto) || $proto;
    my $self  = {};

    my $parent    = shift;
    my $config    = $parent->config;
    my $loglevels = $config->get('loglevels');

    $self->{interactive} = $config->get('logging')->{interactive};
    $self->{debug}       = $config->get('debug');

    if ($config->get('locale')) {
        $self->{locale} = DNSCheck::Locale->new($config->get('locale'));
    }

    if ($loglevels) {
        $self->{loglevels} = $loglevels;
    } else {
        $self->{loglevels} = undef;
    }

    $self->{logname}  = undef;
    $self->{messages} = ();

    $self->{module_stack} = [0];
    $self->{module_id}    = 0;
    
    $self->{start} = time;

    bless $self, $class;
}

sub clear {
    my $self = shift;
    $self->{messages}     = ();
    $self->{module_stack} = [0];
    $self->{module_id}    = 0;
}

sub logname {
    my $self = shift;
    my $arg  = shift;

    if ($arg) {
        $self->{logname} = $arg;
    }

    return $self->{logname};
}

sub add {
    my $self = shift;

    my @module_stack     = @{ $self->{module_stack} };
    my $module_id        = -1;
    my $parent_module_id = -1;

    if ($#module_stack > 0) {
        $module_id        = $module_stack[$#module_stack];
        $parent_module_id = $module_stack[$#module_stack - 1];
    }

    my $entry;
    $entry->{timestamp} = time;
    $entry->{level}     = shift;
    $entry->{tag}       = shift;
    $entry->{module_id} = $module_id;    # Id of module that logged entry
    $entry->{parent_module_id} =
      $parent_module_id;                 # Id of module that called current one
    $entry->{arg} = [@_];

    push @{ $self->{messages} }, $entry;

    if ($self->{interactive}) {
        $self->print();
        $self->{messages} = ();
    }
}

sub auto {
    my $self = shift;

    my $tag   = shift;
    my $level = undef;

    if ($self->{loglevels}->{$tag}) {
        $level = uc($self->{loglevels}->{$tag});
    } else {
        $level = "DEBUG";
    }

    $self->add($level, $tag, @_);

    # return 1 for ERROR or CRITICAL
    if ($level eq "ERROR" or $level eq "CRITICAL") {
        return 1;
    } else {
        return 0;
    }
}

sub dump {
    my $self = shift;

    my $context = $self->{logname} ? sprintf("%s ", $self->{logname}) : "";

    foreach my $e (@{ $self->{messages} }) {
        printf STDERR (
            "%s:%s%s [%s] %s\n",
            $e->{timestamp}, $context, $e->{level}, $e->{tag},
            join(";", @{ $e->{arg} })
        );
    }
}

sub print {
    my $self   = shift;
    my $locale = shift;

    STDOUT->autoflush(1);

    my $context = $self->{logname} ? sprintf("%s ", $self->{logname}) : "";

    foreach my $e (@{ $self->{messages} }) {
        if ($e->{level} eq 'DEBUG' and !$self->{debug}) {
            next;
        }
        if ($self->{locale}) {
            printf("%7.3f: %s%s %s\n",
                ($e->{timestamp} - $self->{start}), $context, $e->{level},
                $self->{locale}->expand($e->{tag}, @{ $e->{arg} }));

        } else {
            printf("%7.3f: %s%s [%s] %s\n",
                ($e->{timestamp} - $self->{start}), $context, $e->{level}, $e->{tag},
                join(";", @{ $e->{arg} }));
        }
    }
}

sub export {
    my $self = shift;

    my @buffer = ();
    my $context = $self->{logname} ? $self->{logname} : "";

    foreach my $e (@{ $self->{messages} }) {
        my @logentry = (
            $e->{timestamp}, $context, $e->{level}, $e->{tag}, $e->{module_id},
            $e->{parent_module_id},
            @{ $e->{arg} }
        );

        push @buffer, \@logentry;
    }

    return \@buffer;
}

sub count_string {
    my $self   = shift;
    my $string = shift;

    return scalar grep { $_->{level} eq $string } @{ $self->{messages} };
}

sub count_debug    { my $self = shift; return $self->count_string('DEBUG'); }
sub count_info     { my $self = shift; return $self->count_string('INFO'); }
sub count_warning  { my $self = shift; return $self->count_string('WARNING'); }
sub count_notice   { my $self = shift; return $self->count_string('NOTICE'); }
sub count_error    { my $self = shift; return $self->count_string('ERROR'); }
sub count_critical { my $self = shift; return $self->count_string('CRITICAL'); }

sub get_next_entry {
    my $self = shift;

    if (!defined($self->{_iter_index})) {
        $self->{_iter_index} = 0;
    }

    if ($self->{_iter_index} > $#{ $self->{messages} }) {
        $self->{_iter_index} = 0;
        return undef;
    }

    my $e = $self->{messages}[$self->{_iter_index}];
    $self->{_iter_index}++;

    return $e;
}

# module_stack_push() creates a unique (autoincrement) identifier for the
# module that called the function, and saves it in module stack - an array
# of module ids
#
# module_stack_pop() removes one module id from the top of the stack
#
# This way, by calling module_stack_push when entering the module, and
# module_stack_pop when exiting, it is ensured that in module_stack there
# is a valid list of module ids that called the current module. On top of
# the stack is the current module id, and the next one is id of the parent
# module.

sub module_stack_push {
    my $self = shift;
    $self->{module_id}++;
    push @{ $self->{module_stack} }, $self->{module_id};
}

sub module_stack_pop {
    my $self = shift;
    pop @{ $self->{module_stack} };
}

1;

__END__


=head1 NAME

DNSCheck::Logger - Logger Subsystem

=head1 DESCRIPTION

The logger object keeps track of the results from the DNSCheck system.

=head1 METHODS

=over 

=item ->new();

Object creation. Do not use this, use the L<DNSCheck::logger()> method.

=item ->clear();

Delete all current content in the object.

=item ->logname($name);

Set the log name.

=item ->auto(I<tag>, I<arg1>, I<arg2>, ..., I<argN>);

Add an entry to the log. You should only need to use this if you're writing
more tests for DNSCheck. The tag needs to be defined in the locale YAML file,
and the number of arguments specified there must match the number given when
calling the method.

If the I<interactive> key is set in the system's config object, this method
will print the log entry rather than store it internally.

=item ->dump();

Send a textual raw dump of the object's contents to standard error.

=item ->print();

Send a textual dump of the object's contents to standard output. If a locale
is set, the output will be translated from raw tags to human-readable
messages.

=item ->export();

Return a list with all messages currently in the object.

=item ->get_next_entry()

Returns a hashref with the next log entry. If this method has never been alled
before on this object, the "next" entry is the first one. It will then iterate
through the entries until all have been returned, and after that it will
return C<undef>. It is possible to add more entries without upsetting the
iterator. This is, however, not really the intened use. The purpose is to be
able to process all log entries without needing to know anything about their
storage or copying possibly large arrays. See below for an example of use.

=item ->count_debug

=item ->count_info

=item ->count_notice

=item ->count_warning

=item ->count_error

=item ->count_critical

Returns the number of current entries of the various severity levels. The
level a given tag is considered to be is specified in F<policy.yaml>.

=back

=head1 LOG ENTRIES

Each entry in the log is a hash. The L<export()> and L<get_next_entry()>
methods return them, as a list or one at a time. There are a bunch of keys in
the hashes:

=over

=item tag

The message tag, as given when the entry was added. If it can't be found in
F<policy.yaml>, it'll be considered to have no arguments and be of level
DEBUG.

=item timestamp

The time when the entry was added, as a string representing a float value in
seconds since the Unix epoch.

=item level

The severity level, as taken from F<policy.yaml>.

=item arg

A reference to a list with message arguments.

=item module_id

=item parent_module_id

Numbers that represent the call hieararchy of test modules. Used by the
standard web gui.

=back

=head1 EXAMPLES

    use DNSCheck;

    my $dc = DNSCheck->new;

    $dc->zone->test("iis.se");
    
    while (defined(my $entry = $dc->logger->get_next_entry)) {
        print $entry->{tag}
    }
    

=cut
