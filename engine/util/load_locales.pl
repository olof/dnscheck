#!/usr/bin/env perl

use strict;
use warnings;

use DBI;
use YAML::XS 'LoadFile';
use DNSCheck;
use Getopt::Long;

my $verbose = undef;    # Explicit default
my $help    = undef;

GetOptions( 'verbose|v' => \$verbose, 'help|h' => \$help );

if ( $help ) {
    print "$0 [-v] [-h]\n";
    print "    Loads locale files into the database. Database connection info\n";
    print "    is taken from DNSCheck. Suitable YAML files should be in a\n";
    print "    subdirectory 'locale' of the current directory, as in the source\n";
    print "    distribution.\n\n";
    print "    -v    Print some progress information.\n    -h    Print this text and exit.\n\n";

    exit( 0 );
}

my $dbh = DNSCheck->new->dbh;
$dbh->{mysql_enable_utf8} = 1;

unless ( $dbh ) {
    print "Could not get a database handle via DNSCheck.\n";
    exit( 1 );
}

print "Clearing old content.\n" if $verbose;
$dbh->do( q[DELETE FROM `messages`] );
my $sth = $dbh->prepare( q[INSERT INTO `messages` (`tag`, `arguments`, `language`, `formatstring`, `description`) VALUES (?,?,?,?,?)] );

foreach my $filename ( <locale/*.yaml> ) {
    my $data = LoadFile( $filename );
    my $lang = $data->{locale_id};
    print "Inserting '$data->{locale_name}' messages.\n" if $verbose;
    foreach my $tag ( keys %{ $data->{messages} } ) {
        my $row = $data->{messages}{$tag};
        $sth->execute( $tag, $row->{args}, $lang, $row->{format}, $row->{descr} );
    }
}
