#!/usr/bin/perl
#
# $Id$

require 5.8.0;
use warnings;
use strict;

use Getopt::Long;
use Pod::Usage;
use DNSCheck;

my $LOCALE_DIR = '@@LOCALE_DIR@@';

######################################################################

sub main {
    my $help      = 0;
    my $timeout   = 2;
    my $raw       = 0;
    my $locale    = "locale/en.yaml";

    GetOptions(
        'help|?'    => \$help,
        'timeout=i' => \$timeout,
        'raw'       => \$raw,
    ) or pod2usage(2);
    pod2usage(1) if ($help);

    my $zone = shift @ARGV;

    unless ($zone) {
        pod2usage(2);
    }

    unless (-f $locale) {
        $locale = $LOCALE_DIR . "/en.yaml";
    }

    $locale = undef if ($raw);

    my $check = new DNSCheck(
        {
            interactive => 1,
            locale      => $locale,
            udp_timeout => $timeout,
            tcp_timeout => $timeout,
        }
    );

    $check->zone($zone);
}

main();

__END__

=head1 NAME

dnscheck - DNSCheck Tool

=head1 SYNOPSIS

dnscheck [options] zone

Options:

 --help                brief help message
 --raw                 raw log output, suitable for automatic processing
 --timeout=SECONDS     set UDP/TCP timeout
