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
    @flagdomains = @{ $conf->{flagdomain} } if defined($conf->{flagdomain});
    my $current = "";
    my %acc     = ();
    my $name;
    my %changed;
    my $debug = 1;

    $res->axfr_start($conf->{domain}, 'IN') or die;

    while (my $rr = $res->axfr_next) {
        if ($rr->type eq 'NS' or $rr->type eq 'DS') {

            $name = $rr->name;

            if ($name eq $current) {
                push @{ $acc{ $rr->type } }, $rr->string;
            } elsif ($current eq "") {
                $current   = $name;
                $acc{'NS'} = [];
                $acc{'DS'} = [];
                $acc{'A'}  = [];
                push @{ $acc{ $rr->type } }, $rr->string;
            } else {
                $new{$current}{'NS'} = md5_base64(sort(@{ $acc{'NS'} }));
                $new{$current}{'DS'} = md5_base64(sort(@{ $acc{'DS'} }));
                $new{$current}{'A'}  = md5_base64(sort(@{ $acc{'A'} }));

                $current   = $name;
                $acc{'NS'} = [];
                $acc{'DS'} = [];
                $acc{'A'}  = [];
                push @{ $acc{ $rr->type } }, $rr->string;
            }
        } elsif ($rr->type eq 'A') {
            push @{ $acc{'A'} }, $rr->string;
        } else {
            next;
        }
    }
    $new{$current}{'NS'} = md5_base64(sort(@{ $acc{'NS'} }));
    $new{$current}{'DS'} = md5_base64(sort(@{ $acc{'DS'} }));
    $new{$current}{'A'}  = md5_base64(sort(@{ $acc{'A'} }));

    if (@flagdomains
        and !(scalar(grep { $new{$_} } @flagdomains) == scalar(@flagdomains)))
    {
        warn "Incomplete transfer (no flag domain), trying next server.\n";
        die "No more servers to try. Giving up.\n" if (@servers == 0);
        goto AGAIN;
    }

    if (open my $oldfile, '<', $filename) {
        while (defined(my $line = <$oldfile>)) {
            my ($domain, $ns_hash, $ds_hash, $a_hash) = split(/\s+/, $line);
            $old{$domain}{'NS'} = $ns_hash;
            $old{$domain}{'DS'} = $ds_hash;
            $old{$domain}{'A'}  = $a_hash;
        }
        close $oldfile;
    }

    open my $newfile, '>', $filename
      or die "Failed open save file: $!";

    while (my ($domain, $hash) = each %new) {
        if (!defined($old{$domain})) {
            $changed{$domain} = 'NEW';
        } else {
            my $o = $old{$domain};

            next
              if (  $o->{NS} eq $hash->{NS}
                and $o->{DS} eq $hash->{DS}
                and $o->{A}  eq $hash->{A});
            $changed{$domain} = '';
            $changed{$domain} .= 'NS ' if $o->{NS} ne $hash->{NS};
            $changed{$domain} .= 'DS ' if $o->{DS} ne $hash->{DS};
            $changed{$domain} .= 'A '  if $o->{A}  ne $hash->{A};
        }

        printf $newfile "%s\t%s\t%s\t%s\n", $domain, $hash->{'NS'},
          $hash->{'DS'}, $hash->{'A'};
    }

    return %changed;
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
q[INSERT INTO queue (priority,domain,source_id,source_data) VALUES (?,?,?,?)]
);
my $rndc = $dc->config->get("zonediff")->{rndcbin};

system($rndc, 'flush') if (defined($rndc) && -x $rndc);

my %changed = get_changed_domains($dc->config->get("zonediff"));

foreach my $domain (keys %changed) {
    $sth->execute(3, $domain, $source_id, $changed{$domain});
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

=item rndcbin

The full path to the L<rndc> binary to be used to tell the local L<named> to
flush its cache. If not set, or set to something that's not executable by the
userid running the script, it'll just be silently skipped.

=back

