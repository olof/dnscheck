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

package DNSCheck::Test::Zone;

require 5.008;
use warnings;
use strict;

use base 'DNSCheck::Test::Common';

######################################################################

sub test {
    my $self    = shift;
    my $zone    = shift;
    my $history = shift;

    my $parent = $self->parent;
    my $qclass = $self->qclass;
    my $logger = $parent->logger;

    $logger->logname($zone);

    $logger->module_stack_push();
    $logger->auto("ZONE:BEGIN", $zone);

    my ($errors, $testable) = $parent->delegation->test($zone, $history);

    unless ($testable) {
        $logger->auto("ZONE:FATAL_DELEGATION", $zone);
        goto DONE;
    }

    my @ns_at_child = $parent->dns->get_nameservers_at_child($zone, $qclass);

    unless ($ns_at_child[0]) {

        # This shouldn't happen because get_nameservers_at_child was also
        # called in DNSCheck::Test::Delegation->test
        $logger->auto("ZONE:FATAL_NO_CHILD_NS", $zone);
        goto DONE;
    }

    foreach my $ns (@ns_at_child) {
        $errors += $parent->nameserver->test($zone, $ns);
    }

    $errors += $parent->consistency->test($zone);
    $errors += $parent->soa->test($zone);
    $errors += $parent->connectivity->test($zone);
    $errors += $parent->dnssec->test($zone);

  DONE:
    $logger->auto("ZONE:END", $zone);
    $logger->module_stack_pop();

    return $errors;
}

sub test_undelegated {
    my $self        = shift;
    my $zone        = shift;
    my @nameservers = @_;

    my $parent = $self->parent;
    my $qclass = $self->qclass;
    my $logger = $parent->logger;

    my $errors = 0;

    $logger->logname($zone);

    $logger->module_stack_push();
    $logger->auto("ZONE:BEGIN", $zone);

    $parent->dns->nameservers_for_child(@nameservers);

    unless ($nameservers[0]) {

        # Slightly silly, since this is really a calling error
        $logger->auto("ZONE:FATAL_NO_CHILD_NS", $zone);
        goto DONE;
    }

    foreach my $ns (@nameservers) {
        $errors += $parent->nameserver->test_by_ip($zone, $ns);
    }

    $errors += $parent->soa->test_undelegated($zone);
    $errors += $parent->connectivity->test($zone);

  DONE:

    $parent->dns->nameservers_for_child(undef);
    $logger->auto("ZONE:END", $zone);
    $logger->module_stack_pop();

    return $errors;
}

1;

__END__


=head1 NAME

DNSCheck::Test::Zone - Test a zone

=head1 DESCRIPTION

Test a zone using all DNSCheck modules, or test an undelegated zone at given
servers with all tests that make sense.

=head1 METHODS

new(I<$parent>)

test(I<zone>, [I<$history>])

test_undelegated(I<$zone>, I<@nameservers>)

=head1 EXAMPLES

=head1 SEE ALSO

L<DNSCheck>, L<DNSCheck::Logger>, L<DNSCheck::Test::Delegation>,
L<DNSCheck::Test::Nameserver>, L<DNSCheck::Test::Consistency>,
L<DNSCheck::Test::SOA>, L<DNSCheck::Test::Connectivity>,
L<DNSCheck::Test::DNSSEC>

=cut
