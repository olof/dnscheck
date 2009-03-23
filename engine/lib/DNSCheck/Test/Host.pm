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

package DNSCheck::Test::Host;

require 5.008;
use warnings;
use strict;

our $SVN_VERSION = '$Revision$';

use base 'DNSCheck::Test::Common';

######################################################################

sub test {
    my $self     = shift;
    my $parent   = $self->parent;
    my $hostname = shift;

    return unless $parent->config->should_run;

    my $qclass = $self->qclass;
    my $logger = $parent->logger;
    my $errors = 0;

    $logger->module_stack_push();
    $logger->auto("HOST:BEGIN", $hostname);

    $errors += $self->host_syntax($hostname);
    goto DONE if $errors > 0;

    my $ipv4 = $parent->dns->query_resolver($hostname, $qclass, "A")
        if $parent->config->get("net")->{ipv4};
    my $ipv6 = $parent->dns->query_resolver($hostname, $qclass, "AAAA")
        if $parent->config->get("net")->{ipv6};

    # REQUIRE: Host address must exist
    unless (($ipv4 && $ipv4->header->ancount)
        || ($ipv6 && $ipv6->header->ancount))
    {
        $errors += $logger->auto("HOST:NOT_FOUND", $hostname);
        goto DONE;
    }

    my @answers = ();
    push @answers, $ipv4->answer if ($ipv4 && $ipv4->header->ancount);
    push @answers, $ipv6->answer if ($ipv6 && $ipv6->header->ancount);

    # REQUIRE: Host must not point to a CNAME
    foreach my $rr (@answers) {
        if ($rr->type eq "CNAME") {
            $errors += $logger->auto("HOST:CNAME_FOUND", $hostname);
            goto DONE;
        }
    }

    # REQUIRE: All host addresses must be valid
    foreach my $rr (@answers) {
        if ($rr->type eq "A" or $rr->type eq "AAAA") {
            if (my $tmp = $parent->address->test($rr->address)) {
                $errors += $tmp;
                goto DONE;
            }
        }
    }

  DONE:
    $logger->auto("HOST:END", $hostname);
    $logger->module_stack_pop();

    return $errors;
}

sub host_syntax {
    my $self     = shift;
    my $hostname = shift;

    return unless $self->parent->config->should_run;

    my @labels = split(/\./, $hostname);

    # REQUIRE: RFC 952 says first component must begin with a-z, and that
    #          labels may not end with a dash.

    # REQUIRE: RFC 1123 allows an initial digit

    # REQUIRE: RFC 2181 spells out that a label may be from 1 to 63 octets
    #          (inclusive) and the whole name at most 255 octets including
    #          separators.

    # REQUIRE: RFC 3696 spells out that the top-level label may not be
    #          all-numeric
    if (length($hostname) > 255) {
        return $self->logger->auto("HOST:ILLEGAL_NAME", $hostname, "Too long");
    }

    foreach my $label (@labels) {
        unless ($label =~ m|^[a-z0-9]|i
            && $label =~ m|^.[-a-z0-9]*.?$|i
            && $label =~ m|[a-z0-9]$|i
            && length($label) <= 63)
        {
            return $self->logger->auto("HOST:ILLEGAL_NAME", $hostname, $label);
        }
    }

    unless ($labels[-1] =~ m|[a-z]|i) {
        return $self->logger->auto("HOST:ILLEGAL_NAME", $hostname,
            "Top all-numeric");
    }

    return 0;
}

1;

__END__


=head1 NAME

DNSCheck::Test::Host - Test host names and addresses

=head1 DESCRIPTION

Test host names and addresses. The following tests are made:

=over 4

=item *
Hostnames may contain the characters a-z, 0-9 and -.

=item *
Last character of hostname must not be a minus sign.

=item *
Host address must exist.

=item *
Hostname must nu point to a CNAME.

=item *
All host addresses (IPv4 and IPv6) must be valid.

=back

=head1 METHODS

test(I<parent>, I<hostname>);

host_syntax(I<hostname>);

=head1 EXAMPLES

=head1 SEE ALSO

L<DNSCheck>, L<DNSCheck::Logger>, L<DNSCheck::Test::Address>

=cut
