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

require 5.8.0;
use warnings;
use strict;
use Time::HiRes qw(gettimeofday);
use DNSCheck::Locale;

######################################################################

sub new {
    my $proto = shift;
    my $class = ref($proto) || $proto;
    my $self  = {};

    my $config = shift;

    if ($config->{interactive}) {
        $self->{interactive} = 1;
    }

    if ($config->{locale}) {
        $self->{locale} = new DNSCheck::Locale($config->{locale});
    }

    $self->{logname}  = undef;
    $self->{messages} = ();
    $self->{errors}   = 0;
    $self->{warnings} = 0;
    $self->{debugs}   = 0;

    bless $self, $class;
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

    my $entry;
    $entry->{timestamp} = join(".", gettimeofday);
    $entry->{level}     = shift;
    $entry->{tag}       = shift;
    $entry->{arg}       = [@_];

    push @{ $self->{messages} }, $entry;

    if ($self->{interactive}) {
        $self->dump();
        $self->{messages} = ();
    }
}

sub info {
    my $self = shift;
    $self->add("INFO", @_);
}

sub notice {
    my $self = shift;
    $self->add("NOTICE", @_);
}

sub warning {
    my $self = shift;
    $self->add("WARNING", @_);
    $self->{warnings}++;
}

sub error {
    my $self = shift;
    $self->add("ERROR", @_);
    $self->{errors}++;
}

sub debug {
    my $self = shift;
    $self->add("DEBUG", @_);
    $self->{debugs}++;
}

sub critical {
    my $self = shift;
    $self->add("CRITICAL", @_);
    $self->{errors}++;
}

sub dump {
    my $self = shift;

    my $context = $self->{logname} ? sprintf("%s ", $self->{logname}) : "";

    foreach my $e (@{ $self->{messages} }) {
        if ($self->{locale}) {
            printf("%s:%s%s %s\n",
                $e->{timestamp}, $context, $e->{level},
                $self->{locale}->expand($e->{tag}, @{ $e->{arg} }));

        } else {
            printf("%s:%s%s [%s] %s\n",
                $e->{timestamp}, $context, $e->{level}, $e->{tag},
                join(",", @{ $e->{arg} }));
        }
    }
}

sub export {
    my $self = shift;

    my @buffer = ();

    my $context = $self->{logname} ? $self->{logname} : "";

    foreach my $e (@{ $self->{messages} }) {
        push @buffer,
          join(
            ";",
            (
                $e->{timestamp}, $context,
                $e->{level},     $e->{tag},
                join(",", @{ $e->{arg} })
            )
          );
    }

    return @buffer;
}

1;

__END__


=head1 NAME

DNSCheck::Looger - Logger Subsystem

=head1 DESCRIPTION

Helper functions for logging support.

=head1 METHODS

new();

$logger->logname(I<string>);

$logger->add(I<level>, I<tag>, I<arg1>, I<arg2>, ..., I<argN>);

$logger->info(I<arg1>, I<arg2>, ..., I<argN>);

$logger->notice(I<arg1>, I<arg2>, ..., I<argN>);

$logger->warning(I<arg1>, I<arg2>, ..., I<argN>);

$logger->error(I<arg1>, I<arg2>, ..., I<argN>);

$logger->debug(I<arg1>, I<arg2>, ..., I<argN>);

$logger->critical(I<arg1>, I<arg2>, ..., I<argN>);

$logger->dump();

my @logmessages = $logger->export();

=head1 EXAMPLES

    use DNSCheck::Logger;

	my $logger = new DNSCheck::Logger;

	$logger->add("foo", 1, 2, 3);
	$logger->add("bar", 4, 5, 6);

	$logger->dump;

=cut
