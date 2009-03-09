#!/usr/bin/perl

use strict;
use warnings;

use Carp;
use Net::DNS;
use DNSCheck;
use Getopt::Long;

my $bootstrap;

# Detect dropped nameservers for a domain and inject them into database

sub get_changed_domains {
    my $conf    = shift;
    my @servers = @{ $conf->{servers} };

    my $filename = $conf->{datafile};
    my $tsig     = $conf->{tsig};

  AGAIN:
    my $server = shift(@servers);
    my $res = Net::DNS::Resolver->new(nameservers => [$server], recurse => 0);

    my %new;
    my %dropped;

    # TSIG for distribution server
    $res->tsig(Net::DNS::RR->new("$tsig")) if defined($tsig);

    my @flagdomains;
    @flagdomains = @{ $conf->{flagdomain} } if defined($conf->{flagdomain});

    $res->axfr_start($conf->{domain}, 'IN') or die "Zone transfer failed.\n";

    while (my $rr = $res->axfr_next) {
        next unless $rr->type eq 'NS';

        $new{ $rr->name }{ $rr->nsdname } = 1;
    }

    if (@flagdomains
        and !(scalar(grep { $new{$_} } @flagdomains) == scalar(@flagdomains)))
    {
        warn "Incomplete transfer (no flag domain), trying next server.\n";
        die "No more servers to try. Giving up.\n" if (@servers == 0);
        goto AGAIN;
    }

    my %old;
    if (open my $old, '<', $filename) {
        while (defined(my $l = <$old>)) {
            my ($d, @n) = split(/\s+/, $l);
            foreach my $n (@n) {
                $dropped{$d}{$n} = 1 unless $new{$d}{$n};
            }
        }
    }
    
    if (    @flagdomains
        and !(scalar(grep { $old{$_} } @flagdomains) == scalar(@flagdomains))
        and !$bootstrap)
    {
        die "$filename incomplete. Giving up.\n";
    }

    open my $new, '>', $filename or die "Failed to open file for save: $!\n";
    while (my ($k, $v) = each %new) {
        print $new "$k ";
        print $new join " ", keys %{$v};
        print $new "\n";
    }
    close $new;

    if ($bootstrap) {
        return;
    } else {
        return %dropped;
    }
}

GetOptions("bootstrap" => \$bootstrap);

my $dc      = DNSCheck->new;
my %dropped = get_changed_domains($dc->config->get("nsdiff"));

my $sth = $dc->dbh->prepare(
    q[INSERT IGNORE INTO delegation_history (domain, nameserver) VALUES (?,?)]);

while (my ($d, $v) = each %dropped) {
    foreach my $n (keys %{$v}) {
        $sth->execute($d, $n);
    }
}

=head1 NAME

dnscheck-nsdiff - Fetch a zone via AXFR and store dropped NSs in database

=head1 DESCRIPTION

This program is intended to be executed regularly from L<cron> or a similar
scheduler.

=head1 CONFIGURATION

This program gets all its configuration from the same YAML files as the rest
of the L<DNSCheck> system. It looks for its data under the key C<nsdiff>. It
looks for five subkeys:

=over

=item tsig

The signature to be used to authorise the transfer, if one is needed. Should
be in a format that can be fed dirctly to L<Net::DNS::RR::new> (which is for
practical purposes the same as you'd put in a zone file: "keyname TSIG
keydata"). If this key is set to an empty value, TSIG will not be used.

=item datafile

The full path to the file where zone names and NS names will be stored
between runs.

=item servers

A list of servers to try to do the zone transfer from. They will be tried in
the order listed.

=item flagdomain

A list of special domain names thats will be present if the entire zone was
correctly transferred. If one or more of the listed domains are missing after
the transfer has concluded, it will be assumed that the transfer was
incomplete and a new attempt will be made with the next server. If there are
no more servers to try, the script will exit with an error message. If this
key is not present, the check will not be made.

=item domain

The domain to check.

=back

