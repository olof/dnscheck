#!/usr/bin/perl

use strict;
use warnings;

use Carp;
use Storable;
use DNSCheck;
use Getopt::Long;

my $bootstrap;
my $debug;

sub download_zone {
    my $conf = shift;

    my $dig  = $conf->{dig};
    my $tsig = $conf->{tsig};
    $tsig =~ s/ TSIG /:/;
    my @servers = @{ $conf->{servers} };
    my $domain  = $conf->{domain};
    my @flagdomains;

    @flagdomains = @{ $conf->{flagdomain} } if defined($conf->{flagdomain});

    my %new;
    my %newns;

    while (my $server = shift @servers) {
        open my $pipe, '-|', $dig, $domain, '@' . $server, 'axfr', '-y', $tsig
          or die "Failed to run dig: $!\n";
        while (defined(my $line = <$pipe>)) {
            next if $line =~ /^;/;
            printf("%10d\r", $.) if $debug;
            chomp($line);
            if (
                my ($name, $type, $rest) =
                $line =~ m/
            ^
            ([-.a-z0-9]+)\. # Name
            \s+
            \d+           # TTL
            \s+
            IN
            \s+
            ((?:NS)|(?:DS)|(?:A))     # Type
            \s+
            (.+)          # Rest
            $
            /x
              )
            {
                push @{ $new{$name}{$type} }, $rest;
                if ($type eq 'NS') {
                    $newns{$name}{$rest} = 1;
                }
                
            }
        }
        print "\n" if $debug;

        if (@flagdomains
            and
            !(scalar(grep { $new{$_} } @flagdomains) == scalar(@flagdomains)))
        {
            warn "Incomplete transfer (no flag domain), trying next server.\n";
            die "No more servers to try. Giving up.\n" if (@servers == 0);
            next;
        } else {
            last;
        }
    }

    return \%new, \%newns;
}

# We want to test a domain if:
#
#  * a domain has been added
#
#  * a domain has had changes in NS
#
#  * a domain has had changes in DS

sub get_changed_domains {
    my $conf     = shift;
    my $filename = $conf->{datafile};
    my @flagdomains;
    my %changed;
    my %dropped;

    @flagdomains = @{ $conf->{flagdomain} } if defined($conf->{flagdomain});

    my ($new, $newns) = download_zone($conf);

    my $old;
    eval { $old = retrieve($filename); };
    print "Old data loaded.\n" if $debug;

    if (    @flagdomains
        and !(scalar(grep { $old->{$_} } @flagdomains) == scalar(@flagdomains))
        and !$bootstrap)
    {
        die "$filename corrupt. Giving up.\n";
    }

    rename $filename, $filename . '.bak';
    store $new, $filename;

    foreach my $domain (keys %$new) {
        printf("%70s\r", $domain) if $debug;
        if (!defined($old->{$domain})) {
            $changed{$domain} = 'NEW';
        } else {
            my $o = $old->{$domain};
            my $n = $new->{$domain};

            next
              if (  norm($o->{NS}) eq norm($n->{NS})
                and norm($o->{DS}) eq norm($n->{DS})
                and norm($o->{A})  eq norm($n->{A}));
            $changed{$domain} = '';
            $changed{$domain} .= 'NS ' if norm($o->{NS}) ne norm($n->{NS});
            $changed{$domain} .= 'DS ' if norm($o->{DS}) ne norm($n->{DS});
            $changed{$domain} .= 'A '  if norm($o->{A})  ne norm($n->{A});
        }
    }
    print "\n" if $debug;
    
    foreach my $domain (keys %$old) {
        next unless $old->{$domain}{NS};
        foreach my $ns (@{$old->{$domain}{NS}}) {
            unless ($newns->{$domain}{$ns}) {
                printf("Adding %s for %s to list of dropped nameservers.\n", $ns, $domain) if $debug;
                $dropped{$domain}{$ns} = 1;
            }
        }
    }

    if ($bootstrap) {
        return;
    } else {
        return \%changed,\%dropped;
    }
}

sub norm {
    my $r = shift;

    if ($r) {
        return join '', sort @$r;
    } else {
        return '';
    }
}

sub get_source_id {
    my $dc  = shift;
    my $dbh = $dc->dbh;

    $dbh->do(q[INSERT IGNORE INTO source (name) VALUES (?)],
        undef, $dc->config->get("zonediff")->{sourcestring});
    my @res = $dbh->selectrow_array(q[SELECT id FROM source WHERE name = ?],
        undef, $dc->config->get("zonediff")->{sourcestring});

    print "Got source id " . $res[0] . "\n" if $debug;
    return $res[0];
}

GetOptions("bootstrap" => \$bootstrap, "debug" => \$debug);

my $dc        = DNSCheck->new;
my $source_id = get_source_id($dc);
my $sth       = $dc->dbh->prepare(
q[INSERT INTO queue (priority,domain,source_id,source_data) VALUES (?,?,?,?)]
);
my $drop_sth = $dc->dbh->prepare(
    q[INSERT IGNORE INTO delegation_history (domain, nameserver) VALUES (?,?)]);
    
my ($changed, $dropped) = get_changed_domains($dc->config->get("zonediff"));

foreach my $domain (keys %$changed) {
    printf("Queueing zone %s for test because of %s.\n",
        $domain, $changed->{$domain})
      if $debug;
    $sth->execute(3, $domain, $source_id, $changed->{$domain});
}

while (my ($d, $v) = each %$dropped) {
    foreach my $n (keys %{$v}) {
        $n =~ s/\.$//;
        printf("Inserting %s for %s into delegation history.\n", $n, $d);
        $drop_sth->execute($d, $n);
    }
}


=head1 NAME

dnscheck-zonediff - Fetch a zone with dig and schedule tests for those changed

=head1 DESCRIPTION

This program does a zone transfer of an entire domain, accumulates the NS and
DS records for each name in it, looks at the sorted and
concatenated string representations of the records and sees if they are the
same as it was the last time the script was run. Any domain for which they
are not the same is entered into the C<queue> table in the L<DNSCheck>
database.

It also looks at NS records, and adds those that exist in the saved file from
the last run but not in the current run to the database table
C<delegation_history>.

This program is intended to be executed regularly from L<cron> or a similar
scheduler.

=head1 CONFIGURATION

This program gets all its configuration from the same YAML files as the rest
of the L<DNSCheck> system. It looks for its data under the key C<zonediff>. It
looks for six subkeys:

=over

=item tsig

The signature to be used to authorise the transfer, if one is needed. Should
be in a format that can be fed dirctly to L<Net::DNS::RR::new> (which is for
practical purposes the same as you'd put in a zone file: "keyname TSIG
keydata"). If this key is set to an empty value, TSIG will not be used.

=item datafile

The full path to the file where zone names and record contents will be stored
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

The file with saved data from a previous run will also be checked for the
existence of the flag domains, and the run terminated if they're not there. In
order to initally populate a save file, or after the list of flag domains has
been changed, run the program with the C<--bootstrap> flag.

=item domain

The domain to check.

=item sourcestring

The string used to mark tests queued from this script.

=item dig

The full path to the L<dig> binary to use for zone transfers.

=back

