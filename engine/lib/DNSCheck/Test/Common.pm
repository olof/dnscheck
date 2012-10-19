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

package DNSCheck::Test::Common;

require 5.010001;
use warnings;
use strict;

use Carp;

sub new {
    my $proto = shift;
    my $class = ref($proto) || $proto;
    my $self  = {};
    bless $self, $proto;

    $self->{parent} = shift;

    croak "Creating test object without parent" unless defined($self->{parent});

    return $self;
}

sub parent {
    my $self = shift;

    return $self->{parent};
}

sub logger {
    my $self = shift;

    return $self->parent->logger;
}

sub config {
    my $self = shift;

    return $self->parent->config;
}

sub qclass {
    my $self = shift;

    return $self->parent->config->get("dns")->{class};
}

__END__

=head1 NAME

DNSCheck::Test::Common - parent module to all other DNSCheck::Test modules.

=head1 SYNOPSIS

Provides the methods C<new>, C<parent>, C<logger>, C<config> and C<qclass>.

=head1 DESCRIPTION

=over

=item ->new($parent)

Creates a new object and sets the parent object (which in just about all cases
should be a L<DNSCheck> object). Will C<croak> if a parent object is not
provided.

=item ->parent()

Returns the parent object.

=item ->logger()

Returns the parent's logger object (an instance of L<DNSCheck::Logger>, unless
you've done something strange).

=item ->config()

Returns the parent's config object (an instance of L<DNSCheck::Config>, unless
you've done something strange).

=item ->qclass()

Returns the DNS lookup class set in the config object. In practice this might
as well be hardcoded to "IN", since the only test that will ever use anything
else is L<DNSCheck::Test::Nameserver::ns_check_id>.

=back

