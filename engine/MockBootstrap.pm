package MockBootstrap;

use JSON::XS;
use Net::DNS;
use Net::DNS::Resolver;
use Carp;

my $data = {};

our $filename = 'bootstrap.json';

sub import {
    my ( $class, $name ) = @_;

    if ( $name ) {
        $filename = $name . '.json';
    }
}

sub push_unique {
    my ($aref, $data) = @_;
    
    if (scalar(grep {$_ eq $data} @$aref) == 0 ) {
        push @$aref, $data;
    }
}

no warnings 'redefine';
my $orig = *Net::DNS::Resolver::Base::send{CODE};
*Net::DNS::Resolver::Base::send = sub {
    my $p = &$orig( @_ );

    if ( $p ) {
        foreach my $section ( qw[answer authority additional] ) {
            foreach my $rr ( $p->$section ) {
                my $tmp = sprintf( "%s %s %s %s", $rr->name, $rr->class, $rr->type, $rr->rdatastr );
                if (!defined($data->{ $rr->name }{ $rr->type }{ $rr->class }{$section})) {
                    $data->{ $rr->name }{ $rr->type }{ $rr->class }{$section} = [];
                }
                
                push_unique $data->{ $rr->name }{ $rr->type }{ $rr->class }{$section}, $tmp;
            }
        }
    }

    return $p;
};

END {
    open my $fh, '>', $filename or die "Failed to save bootstrap data: $!\n";
    print $fh JSON::XS->new->pretty->encode( $data );
}

1;
