#!/usr/bin/env perl

use utf8;
use strict;
use warnings;
use 5.10.1;

use DBI;
use YAML::XS 'LoadFile';
use DNSCheck;
use Getopt::Long;
use Try::Tiny;

my $quiet = undef;    # Explicit default
my $help  = undef;

GetOptions( 'quiet|q' => \$quiet, 'help|h' => \$help );

if ( $help ) {
    print "$0 [-q] [-h] [sourcefiles ...]\n";
    print "    Loads locale files into the database. Database connection info\n";
    print "    is taken from DNSCheck. Suitable YAML files should be in a\n";
    print "    subdirectory 'locale' of the current directory, as in the source\n";
    print "    distribution.\n\n";
    print "    -q    Don't print progress information.\n    -h    Print this text and exit.\n\n";

    exit( 0 );
}

my $dbh = DNSCheck->new->dbh;

$dbh->{mysql_enable_utf8} = 1;

my @sources = glob( 'locale/*.yaml' );

if ( scalar( @sources ) == 0 ) {
    say "No source files found.";
    exit( 1 );
}

say "Using source files: @sources" unless $quiet;

unless ( $dbh ) {
    say "Could not get a database handle via DNSCheck.";
    exit( 1 );
}

$dbh->begin_work or die $dbh->errstr;
say "Clearing old content." unless $quiet;
$dbh->do( q[DELETE FROM `messages`] );
my $sth = $dbh->prepare( q[INSERT INTO `messages` (`tag`, `arguments`, `language`, `formatstring`, `description`) VALUES (?,?,?,?,?)] );

foreach my $filename ( @sources ) {
    my $data;
    try {
        say "Loading $filename." unless $quiet;
        $data = LoadFile( $filename );
    }
    catch {
        say "Failed to load $filename. Skipping to next." unless $quiet;
        next;
    };
    my $lang = $data->{locale_id};
    print "Inserting '$data->{locale_name}' messages.\n" unless $quiet;
    foreach my $tag ( keys %{ $data->{messages} } ) {
        my $row = $data->{messages}{$tag};
        $sth->execute( $tag, $row->{args}, $lang, $row->{format}, $row->{descr} );
    }
}

$dbh->commit or die $dbh->errstr;
