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

package DNSCheck::Test::DNSSEC;

require 5.008;
use warnings;
use strict;

use base 'DNSCheck::Test::Common';

use Net::DNS 0.59;
use Net::DNS::SEC 0.14;
use Date::Parse;
use POSIX qw(strftime);

######################################################################

sub test {
    my $self   = shift;
    my $parent = $self->parent;
    my $zone   = shift;

    return unless $parent->config->should_run;

    my $qclass = $self->qclass;
    my $logger = $parent->logger;
    my $errors = 0;
    my $flags  = { transport => "tcp", dnssec => 1, aaonly => 1 };
    my $packet;

    my $ds;
    my $dnskey;

    my $child_errors;
    my $child_result;
    my $parent_errors;

    $logger->module_stack_push();
    $logger->auto("DNSSEC:BEGIN", $zone);

    # Query parent for DS
    $logger->auto("DNSSEC:CHECKING_DS_AT_PARENT", $zone);
    $packet =
      $parent->dns->query_parent_nocache($zone, $zone, $qclass, "DS", $flags);
    $ds = _dissect($packet, "DS");
    if ($ds && $#{ $ds->{DS} } >= 0) {
        $logger->auto("DNSSEC:DS_FOUND", $zone);
    } else {
        $logger->auto("DNSSEC:NO_DS_FOUND", $zone);
    }

    # Query child for DNSKEY
    $logger->auto("DNSSEC:CHECKING_DNSKEY_AT_CHILD", $zone);
    $packet =
      $parent->dns->query_child_nocache($zone, $zone, $qclass, "DNSKEY",
        $flags);
    $dnskey = _dissect($packet, "DNSKEY");
    if ($dnskey && $#{ $dnskey->{DNSKEY} } >= 0) {
        $logger->auto("DNSSEC:DNSKEY_FOUND", $zone);
    } else {
        $logger->auto("DNSSEC:DNSKEY_NOT_FOUND", $zone);
    }

    # Determine security status
    $logger->auto("DNSSEC:DETERMINE_SECURITY_STATUS", $zone);
    if ($ds and !$dnskey) {
        $errors += $logger->auto("DNSSEC:INCONSISTENT_SECURITY", $zone);
        goto DONE;
    } else {
        $logger->auto("DNSSEC:CONSISTENT_SECURITY", $zone);
    }

    if (!$dnskey) {
        $logger->auto("DNSSEC:SKIPPED_NO_KEYS", $zone);
        goto DONE;
    }

    if (!$ds and $dnskey) {
        $errors += $logger->auto("DNSSEC:MISSING_DS", $zone);
    }

    ($child_errors, $child_result) = _check_child($parent, $zone, $dnskey);
    $errors += $child_errors;

    # Only check parent if we've found a DS
    if ($ds) {
        $parent_errors =
          _check_parent($parent, $zone, $ds, $dnskey, $child_result);
        $errors += $parent_errors;
    }

    # Check if RRSIGs verifies for their respective RRSETs
    $self->rrsig_validities($zone);

  DONE:
    $logger->auto("DNSSEC:END", $zone);
    $logger->module_stack_pop();
    return $errors;
}

sub rrsig_validities {
    my $self = shift;
    my $zone = shift;

    return unless $self->parent->config->should_run;

    my $dns = $self->parent->dns;

    my @ns;
    my $tmp;

    # Get the nameservers we'll work with
    if ($self->config->get("net")->{ipv4}
        and ($tmp = $dns->get_nameservers_ipv4($zone, 'IN')))
    {
        push @ns, @$tmp;
    }
    if ($self->config->get("net")->{ipv6}
        and ($tmp = $dns->get_nameservers_ipv6($zone, 'IN')))
    {
        push @ns, @$tmp;
    }

    my $result = 0;

    # Loop over nameservers
    foreach my $ns (@ns) {
        my $p =
          $dns->query_explicit($zone, 'IN', 'RRSIG', $ns, { aaonly => 1 });

        if (!defined($p)) {
            $result += $self->logger->auto('DNSSEC:VALIDITIES_SERVER_ERROR');
            next;
        } elsif ($p->header->ancount == 0) {
            $result += $self->logger->auto('DNSSEC:VALIDITIES_NO_SIGNATURES');
            next;
        } else {
            foreach my $rrsig ($p->answer) {

                # Loop over RRSIG records from current nameserver
                my @rrset;
                my @keys;

                # Fetch the RRset that the RRSIG signs.
                my $p =
                  $dns->query_explicit($zone, 'IN', $rrsig->typecovered, $ns,
                    { aaonly => 1 });
                if (!defined($p)) {
                    $result +=
                      $self->logger->auto('DNSSEC:VALIDITIES_SERVER_ERROR');
                    next;
                } elsif ($p->header->ancount == 0) {
                    $result += $self->logger->auto('DNSSEC:RRSET_EMPTY');
                    next;
                } else {
                    @rrset = $p->answer;
                }

                # Fetch all DNSKEY records for the name the RRSIG signs.
                $p =
                  $dns->query_explicit($rrsig->signame, 'IN', 'DNSKEY', $ns,
                    { aaonly => 1 });
                if (!defined($p)) {
                    $result +=
                      $self->logger->auto('DNSSEC:VALIDITIES_SERVER_ERROR');
                    next;
                } elsif ($p->header->ancount == 0) {
                    $result +=
                      $self->logger->auto('DNSSEC:VALIDITIES_KEYS_MISSING');
                    next;
                } else {
                    @keys = $p->answer;
                }

                # Verify signature with keys having the same tag as the RRSIG
                if (
                    $rrsig->verify(
                        \@rrset, grep { $_->keytag eq $rrsig->keytag } @keys
                    )
                  )
                {
                    $result +=
                      $self->logger->auto('DNSSEC:RRSIG_VALIDATES',
                        $rrsig->keytag);
                } else {
                    $result +=
                      $self->logger->auto('DNSSEC:RRSIG_VALIDATION_FAILED',
                        $rrsig->keytag, $rrsig->vrfyerrstr);
                }
            }
        }
    }

    return $result;
}

######################################################################

sub _check_child {
    my $parent = shift;
    my $zone   = shift;
    my $dnskey = shift;

    my $qclass = $parent->config->get("dns")->{class};
    my $logger = $parent->logger;
    my $errors = 0;

    my $flags = { transport => "tcp", dnssec => 1 };

    my $packet;
    my %keyhash;
    my %result;

    my $mandatory_algorithm = 0;
    my $sep                 = 0;

    # initialize result set
    $result{rr}      = undef;
    $result{allkeys} = undef;
    $result{anchors} = ();
    $result{sep}     = ();

    $logger->auto("DNSSEC:CHECKING_CHILD", $zone);

    foreach my $key (@{ $dnskey->{DNSKEY} }) {

        # REQUIRE: a DNSKEY SHOULD NOT be of type RSA/MD5
        if ($key->algorithm == Net::DNS::SEC->algorithm("RSAMD5")) {
            $logger->auto("DNSSEC:DNSKEY_ALGORITHM_NOT_RECOMMENDED",
                $zone, $key->keytag, "RSA/MD5");
        }

        if ($key->algorithm == Net::DNS::SEC->algorithm("RSASHA1")) {
            $mandatory_algorithm++;
        }

        # REQUIRE: a DNSKEY used for RRSIGs MUST have protocol DNSSEC (3)
        if ($key->protocol != 3) {
            $logger->auto("DNSSEC:DNSKEY_SKIP_PROTOCOL",
                $zone, $key->keytag, $key->protocol);
            next;
        }

        # REQUIRE: a DNSKEY used for RRSIGs MUST be a zone key
        unless ($key->flags & 0x0100) {
            $logger->auto("DNSSEC:DNSKEY_SKIP_TYPE", $zone, $key->keytag);
            next;
        }

        $keyhash{ $key->keytag } = $key;

        if ($key->is_sep) {
            $logger->auto("DNSSEC:DNSKEY_SEP", $zone, $key->keytag);
            push @{ $result{sep} }, $key->keytag;
            $sep++;
        }
    }

    # fill result set
    $result{rr} = \%keyhash;
    @{ $result{allkeys} } = keys %keyhash;

    # REQUIRE: at least one DNSKEY SHOULD be RSA/SHA1
    if ($mandatory_algorithm > 0) {
        $logger->auto("DNSSEC:DNSKEY_MANDATORY_FOUND", $zone);
    } else {
        $errors += $logger->auto("DNSSEC:DNSKEY_MANDATORY_NOT_FOUND", $zone);
    }

    unless ($#{ $dnskey->{RRSIG} } >= 0) {

        $packet =
          $parent->dns->query_child_nocache($zone, $zone, $qclass, "RRSIG",
            $flags);

        if (    $packet->header->rcode eq "NOERROR"
            and $packet->header->ancount > 0)
        {
            $errors +=
              $logger->auto("DNSSEC:ADDITIONAL_PROCESSING_BROKEN", $zone);
        } else {
            $errors += $logger->auto("DNSSEC:NO_SIGNATURES", $zone);
        }

        $logger->auto("DNSSEC:CHILD_CHECK_ABORTED", $zone);

        goto DONE;
    }

    # REQUIRE: RRSIG(DNSKEY) MUST be valid and created by a valid DNSKEY
    my $valid_dnskey_signatures = 0;
    foreach my $sig (@{ $dnskey->{RRSIG} }) {
        my $valid = _check_signature($parent, $zone, $sig);

        push @{ $result{anchors} }, $sig->keytag;

        if (_count_in_list($sig->keytag, $result{allkeys}) == 1) {
            $valid_dnskey_signatures += $valid;

            $logger->auto("DNSSEC:DNSKEY_SIGNATURE_OK", $zone, $sig->keytag);
        } else {
            $logger->auto("DNSSEC:DNSKEY_SIGNER_UNPUBLISHED",
                $zone, $sig->keytag);
        }
    }
    if ($valid_dnskey_signatures > 0) {
        ## Enough valid signatures over DNSKEY RRset
        $logger->auto("DNSSEC:DNSKEY_VALID_SIGNATURES", $zone);
    } else {
        ## No valid signatures over the DNSKEY RRset
        $logger->auto("DNSSEC:DNSKEY_NO_VALID_SIGNATURES", $zone);
    }

    # REQUIRE: RRSIG(SOA) MUST be valid and created by a valid DNSKEY
    $packet =
      $parent->dns->query_child_nocache($zone, $zone, $qclass, "SOA", $flags);
    goto DONE unless ($packet);
    my $soa = _dissect($packet, "SOA");
    my $valid_soa_signatures = 0;
    foreach my $sig (@{ $soa->{RRSIG} }) {
        my $valid = _check_signature($parent, $zone, $sig);

        push @{ $result{anchors} }, $sig->keytag;

        if (_count_in_list($sig->keytag, $result{allkeys}) == 1) {
            $valid_soa_signatures += $valid;
            $logger->auto("DNSSEC:SOA_SIGNATURE_OK", $zone, $sig->keytag);
        } else {
            $logger->auto("DNSSEC:SOA_SIGNER_UNPUBLISHED", $zone, $sig->keytag);
        }
    }
    if ($valid_soa_signatures > 0) {
        ## Enough valid signatures over SOA RRset
        $logger->auto("DNSSEC:SOA_VALID_SIGNATURES", $zone);
    } else {
        ## No valid signatures over the SOA RRset
        $logger->auto("DNSSEC:SOA_NO_VALID_SIGNATURES", $zone);
    }

    # FIXME: check signature validation?

  DONE:
    $logger->auto("DNSSEC:CHILD_CHECKED", $zone);
    return ($errors, \%result);
}

######################################################################

sub _check_parent {
    my $parent       = shift;
    my $zone         = shift;
    my $ds           = shift;
    my $dnskey       = shift;
    my $child_result = shift;

    my $qclass = $parent->config->get("dns")->{class};
    my $logger = $parent->logger;
    my $errors = 0;

    my $mandatory_algorithm = 0;

    $logger->auto("DNSSEC:CHECKING_PARENT", $zone);

    foreach my $rr (@{ $ds->{DS} }) {

        my $ds_message = sprintf("DS(%s/%d/%d/%d)",
            $zone, $rr->algorithm, $rr->digtype, $rr->keytag);

        $logger->auto("DNSSEC:PARENT_DS", $zone, $ds_message);

        if ($rr->algorithm == Net::DNS::SEC->algorithm("RSASHA1")) {
            $mandatory_algorithm++;
        }

        if ($rr->algorithm == Net::DNS::SEC->algorithm("RSAMD5")) {
            $logger->auto("DNSSEC:DS_ALGORITHM_MD5");
        }

        # REQUIRE: the DS MUST point to a DNSKEY that is
        # signing the child's DNSKEY RRset
        if (_count_in_list($rr->keytag, $child_result->{anchors}) >= 1) {
            ## DS refers to key signing the DNSKEY RRset
            $logger->auto("DNSSEC:DS_KEYREF_OK", $zone, $ds_message);
        } else {
            ## DS refers to key not signing the DNSKEY RRset
            $logger->auto("DNSSEC:DS_KEYREF_INVALID", $zone, $ds_message);
        }

        # REQUIRE: the DS MAY point to a SEP at the child
        if ($#{ $child_result->{sep} } >= 0) {
            if (_count_in_list($rr->keytag, $child_result->{sep}) > 0) {
                ## Child is using SEP and DS refers to a SEP
                $logger->auto("DNSSEC:DS_TO_SEP", $zone, $ds_message);
            } else {
                ## Child is using SEP and DS refers to a non-SEP
                $logger->auto("DNSSEC:DS_TO_NONSEP", $zone, $ds_message);
            }
        }
    }

    # REQUIRE: at least one DS algorithm SHOULD be of type RSA/SHA1
    if ($mandatory_algorithm > 0) {
        $logger->auto("DNSSEC:DS_MANDATORY_FOUND", $zone);
    } else {
        $errors += $logger->auto("DNSSEC:DS_MANDATORY_NOT_FOUND", $zone);
    }

  DONE:
    $logger->auto("DNSSEC:PARENT_CHECKED", $zone);
    return $errors;
}

######################################################################

sub _dissect {
    my $packet = shift;
    my $qtype  = shift;

    my %response = ();

    return undef unless ($packet);

    foreach my $rr ($packet->answer) {
        if (    $rr->type eq "RRSIG"
            and $qtype ne "RRSIG"
            and $rr->typecovered eq $qtype)
        {
            push @{ $response{RRSIG} }, $rr;
            next;
        }

        if ($rr->type eq $qtype) {
            push @{ $response{$qtype} }, $rr;
            next;
        }
    }

    if ($#{ $response{$qtype} } < 0) {    # FIXME: This must be a bug
        return undef;
    }

    return \%response;
}

sub _check_signature ($$) {
    my $parent = shift;
    my $zone   = shift;
    my $rrsig  = shift;

    my $logger = $parent->logger;

    die "bad call to check_signature()" unless ($rrsig->type eq "RRSIG");

    my $now = time();

    my $inception  = _parse_timestamp($rrsig->siginception);
    my $expiration = _parse_timestamp($rrsig->sigexpiration);

    my $message = sprintf("RRSIG(%s/%s/%s/%d)",
        $rrsig->name, $rrsig->class, $rrsig->typecovered, $rrsig->keytag);

    if ($inception > $now) {
        $logger->auto("DNSSEC:RRSIG_NOT_YET_VALID", $message);
        return 0;
    } elsif ($expiration < $now) {
        $logger->auto("DNSSEC:RRSIG_EXPIRED", $message);
        return 0;
    } else {
        $logger->auto("DNSSEC:RRSIG_VALID",      $message);
        $logger->auto("DNSSEC:RRSIG_EXPIRES_AT", scalar(gmtime($expiration)));
        return 1;
    }
}

sub _parse_timestamp ($) {
    my $str = shift;

    if ($str =~ /^(\d{4})(\d{2})(\d{2})(\d{2})(\d{2})(\d{2})$/) {
        return str2time("$1-$2-$3 $4:$5:$6", "GMT");
    } else {
        return undef;
    }
}

sub _count_in_list ($$) {
    my $value = shift;
    my $list  = shift;

    my $n = 0;

    foreach my $x (@{$list}) {
        $n++ if ($x == $value);
    }

    return $n;
}

1;

__END__


=head1 NAME

DNSCheck::Test::DNSSEC - Test DNSSEC

=head1 DESCRIPTION

=over 4

=item *
If there exists DS at parent, the child must use DNSSEC.

=item *
If there exists DNSKEY at child, the parent should have a DS.

=item *
A DNSSEC key should not be of type RSA/MD5.

=item *
At least one DNSKEY should be of type RSA/SHA1.

=item *
There may exist a SEP at the child.

=item *
RRSIG(DNSKEY) must be valid and created by a valid DNSKEY.

=item *
RRSIG(SOA) must be valid and created by a valid DNSKEY.

=item *
The DS must point to a DNSKEY signing the child's DNSKEY RRset.

=item *
The DS may point to a SEP at the child.

=item *
At least one DS algorithm should be of type RSA/SHA1.

=back

=head1 METHODS

=over

=item ->test($zonename)

=item ->rrsig_validities($zonename)

=back

=head1 EXAMPLES

=head1 SEE ALSO

L<DNSCheck>, L<DNSCheck::Logger>

=cut
