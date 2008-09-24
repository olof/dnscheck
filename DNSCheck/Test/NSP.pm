#!/usr/bin/perl
#
# $Id: Host.pm 375 2008-08-22 16:33:09Z jakob $
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

package DNSCheck::Test::NSP;

require 5.8.0;
use warnings;
use strict;

use DNSCheck::NSP;

######################################################################

sub test {
    my $context  = shift;
    my $zone     = shift;
    my $dbh      = shift;
    my @ns       = @_;

    my $logger = $context->logger;

    $logger->module_stack_push();
    $logger->auto("NSP:BEGIN", $zone);

    my $nsp = DNSCheck::NSP->new_with_context($context, $dbh);
    foreach my $ns (@ns) {
        my ($operator, $email) = $nsp->ns_operator($ns);
        if (defined($operator)) {
            $logger->auto("NSP:OPERATOR_FOR_NS", $ns, $operator, $email)
        }
    }

    $logger->auto("NSP:END", $zone);
    $logger->module_stack_pop();

    # The number of errors we found. Since we're not a test, that's zero.
    return 0; 
}

1;

__END__


=head1 NAME

DNSCheck::Test::NSP - Hook gathering of NSP data into the test sequence

=head1 DESCRIPTION

=head1 METHODS

test(I<$context>, I<@ns_servers>);

=head1 EXAMPLES

=head1 SEE ALSO

L<DNSCheck::NSP>

=cut
