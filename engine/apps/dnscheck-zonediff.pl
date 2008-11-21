#!/usr/bin/perl

use strict;
use warnings;

use Carp;
use Net::DNS;
use Digest::MD5 qw[md5_base64];
use DNSCheck;

# We want to test a domain if:
#
#  * a domain has been added
#
#  * a domain has had changes in NS
#
#  * a domain has had changes in DS

sub get_changed_domains {
    my $conf    = shift;
    my @servers = @{ $conf->{servers} };

    my $filename = $conf->{datafile};
    my $tsig     = $conf->{tsig};

  AGAIN:
    my $server = shift(@servers);
    my $res = Net::DNS::Resolver->new(nameservers => [$server], recurse => 0);

    # TSIG for distribution server
    $res->tsig(Net::DNS::RR->new("$tsig")) if defined($tsig);

    my %new;
    my %old;
    my @flagdomains;
    @flagdomains = @{$conf->{flagdomain}} if defined($conf->{flagdomain});
    my $current    = "";
    my @acc        = ();
    my $name;
    my @changed;
    my $debug = 1;
    my $count = 0;

    $res->axfr_start($conf->{domain}, 'IN') or die;

    while (my $rr = $res->axfr_next) {
        next unless ($rr->type eq 'NS' or $rr->type eq 'DS');

        $name = $rr->name;

        if ($name eq $current) {
            push @acc, $rr->string;
        } elsif ($current eq "") {
            $current = $name;
        } else {
            $new{$current} = md5_base64(sort(@acc));
            @acc = ();
            if ($count++ % 1000 == 0) {
                # print STDERR "$name\n";
            }

            $current = $name;
        }
    }
    $new{$name} = md5_base64(sort(@acc));

    if (@flagdomains and !(scalar(grep {$new{$_}} @flagdomains) == scalar(@flagdomains))) {
        warn "Incomplete transfer (no flag domain), trying next server.\n";
        die "No more servers to try. Giving up.\n" if (@servers == 0);
        goto AGAIN;
    }

    open my $oldfile, '<', $filename;
    if ($oldfile) {
        while (defined(my $line = <$oldfile>)) {
            my ($domain, $hash) = split(/\s+/, $line);
            $old{$domain} = $hash;
        }
        close $oldfile;
    }

    open my $newfile, '>', $filename
      or die "Failed open save file: $!";

    while (my ($domain, $hash) = each %new) {
        if (!defined($old{$domain}) or ($hash ne $old{$domain})) {
            push @changed, $domain;
        }
        print $newfile "$domain\t$hash\n";
    }

    return @changed;
}

sub get_source_id {
    my $dc  = shift;
    my $dbh = $dc->dbh;

    $dbh->do(q[INSERT IGNORE INTO source (name) VALUES (?)],
        undef, $dc->config->get("zonediff")->{sourcestring});
    my @res = $dbh->selectrow_array(q[SELECT id FROM source WHERE name = ?],
        undef, $dc->config->get("zonediff")->{sourcestring});

    return $res[0];
}

my $dc        = DNSCheck->new;
my $source_id = get_source_id($dc);
my $sth       = $dc->dbh->prepare(
    q[INSERT INTO queue (priority,domain,source_id) VALUES (?,?,?)]);

foreach my $domain (get_changed_domains($dc->config->get("zonediff"))) {
    $sth->execute(3, $domain, $source_id);
}

=head1 NAME

dnscheck-zonediff - Fetch a zone via AXFR and schedule tests for those changed

=head1 DESCRIPTION

This program does a zone transfer of an entire domain, accumulates the NS and
DS records for each name in it, calculates an MD5 hash on the sorted and
concatenated string representations of the records and sees if the sum is the
same as it was the last time the script was run. Any domain for which the sum
is not the same is entered into the C<queue> table in the L<DNSCheck>
database.

This program is intended to be executed regularly from L<cron> or a similar
scheduler.

=head1 CONFIGURATION

This program gets all its configuration from the same YAML files as the rest
of the L<DNSCheck> system. It looks for its data under the key C<zonediff>. It
looks for five subkeys:

=over

=item tsig

The signature to be used to authorise the transfer, if one is needed. Should
be in a format that can be fed dirctly to L<Net::DNS::RR::new> (which is for
practical purposes the same as you'd put in a zone file: "keyname TSIG
keydata"). If this key is set to an empty value, TSIG will not be used.

=item datafile

The full path to the file where zone names and MD5 hashes will be stored
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

=item sourcestring

The string used to mark tests queued from this script.

=back

