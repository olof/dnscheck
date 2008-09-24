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

package DNSCheck::Test::Delegation;

require 5.8.0;
use warnings;
use strict;

######################################################################

sub test {
    my $context = shift;
    my $zone    = shift;
    my $history = shift;

    my $qclass = $context->qclass;
    my $logger = $context->logger;
    my $errors = 0;

    my $testable = undef;

    $logger->module_stack_push();
    $logger->auto("DELEGATION:BEGIN", $zone);

    my $packet;

    my @ns_at_parent = $context->dns->get_nameservers_at_parent($zone, $qclass);
    @ns_at_parent = () unless $ns_at_parent[0];
    if (scalar @ns_at_parent) {
        $logger->auto("DELEGATION:NS_AT_PARENT", join(",", @ns_at_parent));
        $testable = 1;
    } else {
        $errors += $logger->auto("DELEGATION:NOT_FOUND_AT_PARENT");
        $testable = 0;
    }

    goto DONE if ($errors);

    my @ns_at_child = $context->dns->get_nameservers_at_child($zone, $qclass);
    @ns_at_child = () unless $ns_at_child[0];
    if (scalar @ns_at_child) {
        $logger->auto("DELEGATION:NS_AT_CHILD", join(",", @ns_at_child));
    } else {
        $errors += $logger->auto("DELEGATION:NOT_FOUND_AT_CHILD");
        $testable = 0;
    }

    # REQUIRE: all NS at parent must exist at child [IIS.KVSE.001.01/r2]
    foreach my $ns (@ns_at_parent) {
        unless (scalar grep(/^$ns$/i, @ns_at_child)) {
            $errors += $logger->auto("DELEGATION:EXTRA_NS_PARENT", $ns);
        }
    }

    # REQUIRE: all NS at child may exist at parent
    foreach my $ns (@ns_at_child) {
        unless (scalar grep(/^$ns$/i, @ns_at_parent)) {
            $logger->auto("DELEGATION:EXTRA_NS_CHILD", $ns);
        }
    }

    # REQUIRE: at least two (2) NS records at parent [IIS.KVSE.001.01/r1]
    unless (scalar @ns_at_parent >= 2) {
        $logger->auto("DELEGATION:TOO_FEW_NS", scalar @ns_at_parent);
    }

    # REQUIRE: at least two IPv4 nameservers must be found
    my $ipv4_ns = $context->dns->get_nameservers_ipv4($zone, $qclass);
    if ($ipv4_ns && scalar(@{$ipv4_ns} < 2)) {
        $logger->auto("DELEGATION:TOO_FEW_NS_IPV4", scalar @{$ipv4_ns});
    }
    unless ($ipv4_ns) {
        $logger->auto("DELEGATION:NO_NS_IPV4");
    }

    # REQUIRE: at least two IPv6 nameservers should be found
    my $ipv6_ns = $context->dns->get_nameservers_ipv6($zone, $qclass);
    if ($ipv6_ns && scalar(@{$ipv6_ns} < 2)) {
        $logger->auto("DELEGATION:TOO_FEW_NS_IPV6", scalar @{$ipv6_ns});
    }
    unless ($ipv6_ns) {
        $logger->auto("DELEGATION:NO_NS_IPV6");
    }

    # REQUIRE: check for inconsistent glue
    my @glue = _get_glue($context, $zone);
    foreach my $g (@glue) {
        $logger->auto("DELEGATION:MATCHING_GLUE", $g->name, $g->address);

        # make sure we only check in-zone-glue
        unless ($g->name =~ /$zone$/i) {
            $logger->auto("DELEGATION:GLUE_SKIPPED", $g->name, "out-of-zone");
            next;
        }

        my $c =
          $context->dns->query_child($zone, $g->name, $g->class, $g->type);

        if ($c and $c->header->rcode eq "NOERROR") {
            ## got NOERROR, might be good or bad - dunno yet

            if ($c->header->ancount > 0) {
                ## got positive answer back, let's see if this makes any sense

                my $found = 0;
                foreach my $rr ($c->answer) {
                    if (    lc($rr->name) eq lc($g->name)
                        and $rr->class   eq $g->class
                        and $rr->type    eq $g->type
                        and $rr->address eq $g->address)
                    {
                        $logger->auto("DELEGATION:GLUE_FOUND_AT_CHILD",
                            $zone, $g->name, $g->address);
                        $found++;
                    }
                }

                unless ($found) {
                    $logger->auto("DELEGATION:INCONSISTENT_GLUE", $g->name);
                }
            } elsif ($c->header->nscount > 0) {
                ## got referer or nothing, authority section needs study

                my $soa = undef;
                my $ns  = undef;

                foreach my $rr ($c->authority) {
                    $soa = $rr if ($rr->type eq "SOA");
                    $ns  = $rr if ($rr->type eq "NS");
                }

                ## got NOERROR and NS in authority section -> referer
                if ($ns) {
                    $logger->auto("DELEGATION:GLUE_SKIPPED", $g->name,
                        "referer");
                    next;
                }

                ## got NOERROR and SOA in authority section -> not found
                if ($soa) {
                    $logger->auto("DELEGATION:GLUE_MISSING_AT_CHILD", $g->name);
                    next;
                }
            }
        } elsif ($c and $c->header->rcode eq "REFUSED") {
            ## got REFUSED, probably not authoritative
            $logger->auto("DELEGATION:GLUE_SKIPPED", $g->name, "refused");
            next;
        } elsif ($c and $c->header->rcode eq "SERVFAIL") {
            ## got SERVFAIL, most likely not authoritative
            $logger->auto("DELEGATION:GLUE_SKIPPED", $g->name, "servfail");
            next;
        } else {
            ## got something else, let's blame the user...
            $logger->auto("DELEGATION:GLUE_MISSING_AT_CHILD", $g->name);
            next;
        }
    }

    # Test old namservers if we have history
    if ($history) {
        _history($context, $zone, \@ns_at_parent, $history);
    }

    # TODO: check for loop in glue record chain (i.e. unresolvable)

    # TODO: warning if glue chain is longer than 3 lookups

  DONE:
    $logger->auto("DELEGATION:END", $zone);
    $logger->module_stack_pop();

    return ($errors, $testable);
}

######################################################################

sub _get_glue {
    my $context = shift;
    my $zone    = shift;

    my $qclass = $context->qclass;
    my $logger = $context->logger;

    my @glue = ();

    my @ns = $context->dns->get_nameservers_at_parent($zone, $qclass);
    @ns = () unless $ns[0];

    foreach my $nameserver (@ns) {
        my $ipv4 =
          $context->dns->query_parent($zone, $nameserver, $qclass, "A");

        if ($ipv4) {
            my @sorted_ipv4 =
              sort { $a->{name} cmp $b->{name} }
              ($ipv4->answer, $ipv4->additional);

            foreach my $rr (@sorted_ipv4) {
                if ($rr->type eq "A" and $rr->name eq $nameserver) {
                    $logger->auto("DELEGATION:GLUE_FOUND_AT_PARENT",
                        $zone, $rr->name, $rr->address);
                    push @glue, $rr;
                }
            }
        }

        my $ipv6 =
          $context->dns->query_parent($zone, $nameserver, $qclass, "AAAA");

        if ($ipv6) {
            my @sorted_ipv6 =
              sort { $a->{name} cmp $b->{name} }
              ($ipv6->answer, $ipv6->additional);

            foreach my $rr (@sorted_ipv6) {
                if ($rr->type eq "AAAA" and $rr->name eq $nameserver) {
                    $logger->auto("DELEGATION:GLUE_FOUND_AT_PARENT",
                        $zone, $rr->name, $rr->address);
                    push @glue, $rr;
                }
            }
        }
    }

    return @glue;
}

sub _history {
    my $context  = shift;
    my $zone     = shift;
    my $current  = shift;
    my $previous = shift;

    my $qclass = $context->qclass;
    my $logger = $context->logger;

    my @old = ();

    # Build a hash with all IP addresses for all current nameservers
    my %current_addresses =
      map { $_ => 1 }
      map { $context->dns->find_addresses($_, $qclass) } @$current;

    # do not check current nameservers
    foreach my $ns (@$previous) {
        unless (grep(/^$ns$/, @$current)) {
            push @old, $ns;
        }
    }

    $logger->auto("DELEGATION:NS_HISTORY", $zone, join(",", @old));

    foreach my $ns (@old) {
        my @addresses = $context->dns->find_addresses($ns, $qclass);

        # FIXME: also skip current IP addresses

        foreach my $address (@addresses) {

            # Skip to next address if this one leads to a current server
            next if $current_addresses{$address};
            my $packet =
              $context->dns->query_explicit($zone, $qclass, "SOA", $address,
                { noservfail => 1 });
            if ($packet && $packet->header->aa) {
                $logger->auto("DELEGATION:STILL_AUTH", $ns, $address, $zone);
            }
        }
    }

    return;
}

1;

__END__


=head1 NAME

DNSCheck::Test::Delegation - Test zone delegation

=head1 DESCRIPTION

Test zone delegation. The following tests are made:

=over 4

=item *
All nameservers at parent must exist at child.

=item *
Nameservers at child may exist at parent.

=item *
# REQUIRE: at least two (2) NS records at parent [IIS.KVSE.001.01/r1]

=item *
# REQUIRE: check for inconsistent glue

=back

=head1 METHODS

test(I<context>, I<zone>);

=head1 EXAMPLES

    use DNSCheck::Context;
    use DNSCheck::Test::Delegation;

    my $context = new DNSCheck::Context();
    DNSCheck::Test::Delegation::test($context, "iis.se");
    $context->logger->dump();

=head1 SEE ALSO

L<DNSCheck>, L<DNSCheck::Context>, L<DNSCheck::Logger>

=cut
