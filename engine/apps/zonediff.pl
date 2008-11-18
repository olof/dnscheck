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
    my $server = 'philby.nic.se';

  AGAIN:
    my $filename = q(/tmp/zone_hashes.txt);
    my $tsigfile = q(tsig.txt);

    my $res = Net::DNS::Resolver->new(nameservers => [$server], recurse => 0);

    # TSIG for distribution server
    open my $sigfile, '<', $tsigfile or die "Failed to open signature file: $!";
    my $tsig = <$sigfile>;
    $res->tsig(Net::DNS::RR->new("$tsig"));

    my %new;
    my %old;
    my $flagdomain = q(zzziiscontrolzoneombudsinformation.se);
    my $current    = "";
    my @acc        = ();
    my $name;
    my @changed;
    my $debug = 1;
    my $count = 0;

    $res->axfr_start('se.', 'IN') or die;

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
                print STDERR "$name\n";
            }

            $current = $name;
        }
    }
    $new{$name} = md5_base64(sort(@acc));

    if (!defined($new{$flagdomain})) {
        warn
"Incomplete zone transfer (flag domain not present), retrying with alternate.";
        $server = 'burgess.nic.se';
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

# Call with a reference to a config hash, such as from $dc->config->get("reggie")
sub reggie_dbh {
    my $conf = shift;
    my $dbh;

    my $dsn = sprintf("DBI:mysql:database=%s;hostname=%s;port=%s",
        $conf->{"database"}, $conf->{"host"}, $conf->{"port"});

    eval {
        $dbh =
          DBI->connect($dsn, $conf->{"user"}, $conf->{"password"},
            { RaiseError => 1, AutoCommit => 1 });
    };
    if ($@) {
        carp "Failed to connect to database: $@";
    }

    return $dbh;
}

sub domain_owner {
    my ($dbh, $domain) = @_;
    my ($name, $email);

    # FIXME: Add code to do the DB lookup

    return ($name, $email);
}

my $dc  = DNSCheck->new;
my $dbh = reggie_dbh($dc->config->get("reggie"));
