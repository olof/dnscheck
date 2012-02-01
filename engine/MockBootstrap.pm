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

# Add a string to an array if it's not already there.
sub push_unique {
    my ($aref, $data) = @_;
    
    if (scalar(grep {$_ eq $data} @$aref) == 0 ) {
        push @$aref, $data;
    }
}

no warnings 'redefine';

# Save a reference to the original code.
my $orig = *Net::DNS::Resolver::Base::send{CODE};

# Replace it with our own.
*Net::DNS::Resolver::Base::send = sub {
    my $p = &$orig( @_ ); # Call the original code

    if ( $p ) {
        my ($q) = $p->question;

        my $qh = $p->header;
        my %sh = (
            'opcode' => $qh->opcode,
            'qr' => $qh->qr,
            'aa' => $qh->aa,
            'tc' => $qh->tc,
            'rd' => $qh->rd,
            'cd' => $qh->cd,
            'ra' => $qh->ra,
            'ad' => $qh->ad,
            'rcode' => $qh->rcode,
        );
        $data->{ $q->qname }{ $q->qtype }{ $q->qclass }{ header } = \%sh;
        foreach my $section ( qw[answer authority additional] ) {
            foreach my $rr ( $p->$section ) {
                my $name = $rr->name || '.';

                if ($rr->type eq 'OPT') { # OPT records are magical, don't save them
                    next;
                }
                
                my $tmp = sprintf( "%s %s %s %s", $name, $rr->class, $rr->type, $rr->rdatastr );
                if (!defined($data->{ $q->qname }{ $q->qtype }{ $q->qclass }{$section})) {
                    $data->{ $q->qname }{ $q->qtype }{ $q->qclass }{$section} = [];
                }
                
                push_unique $data->{ $q->qname }{ $q->qtype }{ $q->qclass }{$section}, $tmp;
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
