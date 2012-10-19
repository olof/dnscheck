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

package DNSCheck::Locale;

require 5.010001;
use warnings;
use strict;

use overload bool => \&_to_boolean;

######################################################################

sub new {
    my $proto = shift;
    my $class = ref($proto) || $proto;
    my $self  = {};

    my $config = shift;

    $self->{name}     = $config->{locale_name};
    $self->{lang}     = $config->{locale_id};
    $self->{messages} = $config->{messages};

    bless $self, $class;
}

sub expand {
    my $self = shift;
    my $tag  = shift;
    my @args = @_;

    my $format = $self->{messages}{$tag}{format};

    if ($format and @args != $self->{messages}{$tag}{args}) {
        warn "invalid number of arguments supplied for $tag";
    }

    if ($format) {
        return sprintf($format, @args);
    } else {
        return sprintf("[MISSING LOCALE] %s %s", $tag, join(",", @args));
    }
}

sub _to_boolean {
    my $self = shift;

    return !!$self->{lang};
}

1;

__END__

=head1 NAME

DNSCheck::Locale - Translation of message tags to human-readable strings

=head1 DESCRIPTION

Module to take internal message tags used by DNSCheck and convert them into 
human-readable text messages in any of the supported languages.

=head1 METHODS

=head2 new()

For internal use only. To get an object, use L<DNSCheck::locale()>.

=head2 expand($tag, @args)

Convert the given tag using the given arguments. If the C<@args> list doesn't 
have exactly the same number of elements as the translation for the tag 
requires, a warning message will be issued on STDERR. If the tag can't be found 
in the currently configured language environment, a fallback message will be 
generated.

=head1 SEE ALSO

L<DNSCheck>
