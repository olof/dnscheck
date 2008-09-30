#!/usr/bin/perl

use warnings;
use strict;

use YAML qw{LoadFile};

unless (@ARGV == 2) {
    print "usage: $0 file1 file2\n";
    exit(1);
}

my $debug = 0;

my $left = LoadFile($ARGV[0]);
my $right = LoadFile($ARGV[1]);

my %res;

foreach my $l (keys %{$left->{messages}}) {
    $res{$l} += 1;
}

foreach my $r (keys %{$right->{messages}}) {
    $res{$r} -= 1;
}

foreach my $k (keys %res) {
    if ($res{$k} == 1) {
        print "$k exists only in $ARGV[0]\n"
    } elsif ($res{$k} == -1) {
        print "$k exists only in $ARGV[1]\n"
    } else {
        print "$k exists in both.\n" if $debug;
    }
}

__END__

=head1 NAME

localecompare - Compare two of DNSCheck's locale files.

=head1 DESCRIPTION

When pointed at two of DNSCheck's locale YAML files, this script will extract all message keys and print out those who only occur in one of the files.

=head1 EXAMPLES

    localecompare.pl locale/en.yaml locale/sv.yaml
    
=cut