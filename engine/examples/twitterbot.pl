#!/opt/local/bin/perl

use warnings;
use strict;

use Net::Twitter;
use DNSCheck;
use SDBM_File;
use Fcntl;

my $dc   = DNSCheck->new;
my $conf = $dc->config->get("twitterbot");
my %db;

tie %db, 'SDBM_File', $conf->{datafile}, O_RDWR | O_CREAT, 0666
  or die "Failed to tie database: $!\n";

my $twitter = Net::Twitter->new(
    username   => $conf->{username},
    password   => $conf->{password},
    clientname => 'DNSCheck TwitterBot',
    clientver  => '1.0',
    clienturl  => 'http://dnscheck.iis.se/',
) or die;

unless (defined($db{since_id})) {
    $db{since_id} = 1;
}

sub update {
    my ($name, $text) = @_;

    my $tmp = substr('@' . $name . ' ' . $text, 0, 140);
    $twitter->update($tmp);

    # print "$tmp\n";
}

sub process {
    my ($name, $text) = @_;

    my ($domain) = $text =~ m/
        (
            (?:\w+\.)+\w+
        )
    /x;

    if (!defined($domain)) {
        update($name,
'Tweet me with a domain name, and I will reply with an assessment of its DNS correctness.'
        );
    } elsif ($dc->dns->preflight_check($domain)) {
        $dc->zone->test($domain);
        my $l = $dc->logger;
        my $msg;
        if ($l->count_critical > 0) {
            $msg =
                $l->count_critical
              . ' critical error'
              . ($l->count_critical == 1 ? '' : 's');
        } elsif ($l->count_error > 0) {
            $msg =
              $l->count_error . ' error' . ($l->count_error == 1 ? '' : 's');
        } elsif ($l->count_warning > 0) {
            $msg =
                $l->count_warning
              . ' warning'
              . ($l->count_warning == 1 ? '' : 's');
        } else {
            $msg = 'No problems';
        }
        update($name, sprintf('%s for %s', $msg, $domain));
    } else {
        update($name, sprintf('%s not found', $domain));
    }
}

my $mentions = $twitter->mentions(
    {
        since_id => $db{since_id},
        count    => 200,
    }
);

foreach my $t (@$mentions) {
    process($t->{user}{screen_name}, $t->{text});
    $db{since_id} = $t->{id} if $t->{id} >= $db{since_id};
}

untie(%db);

=head1 NAME

twitterbot

=head1 SYNOPSIS

Check Twitter for mentions of a given username, look for a domain name in the
returned tweets, test those domains and post reply tweets with (very)
abbreviated test results.

=head1 DESCRIPTION

This script gets all its configuration data via the DNSCheck configuration
system. It will look for three keys under the
top-level key C<twitterbot>:

=over

=item datafile

Where to store persistent data. As of this writing this is only the ID number
of the last tweet responded to, but this may change in the future. Will
actually write two files: the given name with suffixes .dir and .pag.

=item username

The Twitter username to use.

=item password

The password to go with the given Twitter username.

=back

Given a correct setup of those keys, it should work fine running the script
regularly from L<cron>.

=cut
