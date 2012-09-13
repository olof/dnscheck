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

package DNSCheck::Test::SMTP;

require 5.008;
use warnings;
use strict;

use base 'DNSCheck::Test::Common';

use Net::SMTP 2.29;

use IO::Socket::INET;
use IO::Socket::INET6;

BEGIN {

    # Vile hack to make Net::SMTP work with IPv6.
    # Hopefully, at some point in the future Perl itself will be upgraded to
    # handle IPv6 and we can take this abomination out.
    $::{'IO::'}{'Socket::'}{'INET::'} = $::{'IO::'}{'Socket::'}{'INET6::'};
}

######################################################################

sub test {
    my $self     = shift;
    my $hostname = shift;
    my $address  = shift;
    my $email    = shift;

    my $parent = $self->parent;
    my $logger = $parent->logger;
    my $errors = 0;
    my $message;

    return 0 unless $parent->config->should_run;

    unless ($parent->config->get("net")->{smtp}) {
        $logger->auto('SMTP:SKIPPED');
        return 0;
    }

    $logger->module_stack_push();
    $logger->auto("SMTP:BEGIN", $hostname, $address, $email);

    my $smtp = Net::SMTP->new(
        Host    => $address,
        Hello   => $parent->config->get("smtp")->{hostname},
        Timeout => $parent->config->get("smtp")->{timeout},
    );

    unless ($smtp) {
        $logger->auto("SMTP:CONNECT_FAILED", $hostname, $address);
        $errors++;
        goto DONE;
    }

    my @extensions = split(/\n/, $smtp->message);
    shift @extensions;    # Toss server name

    $message = $smtp->banner;
    chomp $message;
    $logger->auto("SMTP:BANNER", $message, join(',', @extensions));

    if ($smtp->status == 0) {
        $logger->auto("SMTP:TIMEOUT");
        goto RESET;
    }

    unless ($smtp->status == 2) {
        $logger->auto("SMTP:HELLO_FAILED");
        $errors++;
        goto DONE;
    }

    $logger->auto("SMTP:MAIL_FROM", "<>");
    $smtp->mail("<>");
    $message = $smtp->message;
    chomp $message;
    $logger->auto("SMTP:RAW", $message);

    if ($smtp->status == 0) {
        $logger->auto("SMTP:TIMEOUT");
        goto RESET;
    }

    unless ($smtp->status == 2) {
        $logger->auto("SMTP:MAIL_FROM_REJECTED", "<>");
        $errors++;
        goto RESET;
    }

    $logger->auto("SMTP:RCPT_TO", $email);
    $smtp->recipient($email);
    $message = $smtp->message;
    chomp $message;
    $logger->auto("SMTP:RAW", $message);

    if ($smtp->status == 0) {
        $logger->auto("SMTP:TIMEOUT");
        goto RESET;
    }

    # accept 2xx (ok) and 4xx (temporary failure, possible greylisting)
    unless ($smtp->status == 2 || $smtp->status == 4) {
        $logger->auto("SMTP:RECIPIENT_REJECTED", $email);
        $errors++;
    }

  RESET:
    $logger->auto("SMTP:RSET");
    $smtp->reset;
    $message = $smtp->message;
    chomp $message;
    $logger->auto("SMTP:RAW", $message);

    $logger->auto("SMTP:QUIT");
    $smtp->quit;
    $message = $smtp->message;
    chomp $message;
    $logger->auto("SMTP:RAW", $message);

    unless ($errors) {
        $logger->auto("SMTP:OK", $hostname, $address, $email);
    }

  DONE:
    $logger->auto("SMTP:END", $hostname, $address, $email);
    $logger->module_stack_pop();

    return $errors;
}

1;

__END__


=head1 NAME

DNSCheck::Test::SMTP - Test SMTP delivery

=head1 DESCRIPTION

Test if an email address is deliverable using SMTP.

=head1 METHODS

=over

=item ->new($parent)

Inherited from L<DNSCheck::Test::Common>

=item ->test($mailhost, $address, $emailaddress);

=head1 EXAMPLES

=head1 SEE ALSO

L<DNSCheck>, L<DNSCheck::Logger>, L<Net::SMTP>

=cut
