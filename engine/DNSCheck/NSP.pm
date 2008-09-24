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

package DNSCheck::NSP;

require 5.8.0;
use warnings;
use strict;

use DNSCheck::Context;
use DBI;

######################################################################

#
# this module will implement the Name Service Provider tracking
# Implementation started by Calle Dybedahl <calle@init.se> 2008-09-19
#

sub new {
    my $proto = shift;
    my $class = ref($proto) || $proto;
    my $self  = {};

    my $config = shift;

    unless ($config->{db_config}) {
        $config->{db_config} = "./dnscheck.conf";
    }

    $self->{dbh} = DBI->connect(
        "DBI:mysql:database=;"
          . "mysql_read_default_group=dnscheck;"
          . "mysql_read_default_file="
          . $config->{db_config},
        undef,
        undef,
        { RaiseError => 1, AutoCommit => 1 }
    ) or die $DBI::errstr;

    unless ($config->{class}) {
        $config->{class} = "IN";
    }

    $self->{context} = DNSCheck::Context->new($config);

    bless $self, $class;
}

# In: domain name. Out: registrar, contact email (if one exists).
sub lookup {
    my $self   = shift;
    my $zone   = shift;
    my $logger = $self->{context}->logger;

    $logger->module_stack_push;
    $logger->auto("NSP:GETTING_CHILD_NAMESERVERS_FOR", $zone);
    my @servers =
      $self->{context}
      ->dns->get_nameservers_at_child($zone, $self->{context}->qclass);
    $logger->module_stack_pop;

    my %operators;
    foreach my $server (@servers) {
        my ($operator, $email) = $self->ns_operator($server);
        next unless (defined($operator) and defined($email));
        $operators{$operator} = $email;
    }

# The following is an if statement in case we want to separate these cases later on.
    if (scalar keys %operators > 1) {
        return %operators;
    } else {
        return %operators;
    }

}

sub ns_operator {
    my $self   = shift;
    my $nsname = shift;

    my $sth =
      $self->dbh->prepare(
"select nsp.name, nsp.email from nsp, nameservers as ns where nsp.id = ns.nsp_id and ns.nameserver = ?"
      );
    $sth->execute($nsname);
    my @res = @{ $sth->fetchall_arrayref };
    if (@res == 0) {
        $self->dbh->do(
            q{
            insert ignore into nameservers (nameserver) values (?)
        }, undef, $nsname
        );
        return ();
    } elsif (@res > 1) {
        die "More than one operator for nameserver: database broken?";
    } else {
        return @{ $res[0] };    # Two-item list with name and email, hopefully
    }
    die "ns_operator fell through to end: this should be impossible.";
}

sub dbh {
    my $self = shift;

    return $self->{dbh};
}

1;

__END__

=head1 NAME

DNSCheck::NSP - Name Service Provider Lookup

=head1 DESCRIPTION

Module that tries to figure out which operator a certain domain is using for its name service.

=head1 METHODS

=over

=item ->new($confighashref)

Returns a new DNSCheck::NSP object to use for lookups. Getting an object and using it repeatedly is recommended, since this means database connections and remote DNS lookups will be cached. The config hash reference is the same one used in other DNSCheck modules.

=item ->lookup($domainname)

Look up data for a domain. Returns a list of strings with alternating operator names and email adresses, suitable for assigning to a hash. If there is no information an empty list is returned.

=back

