package MockResolver;

use JSON::XS;
use Net::DNS;
use File::Slurp;
use Carp;

# This is where we store the mockup data.
our $data;

# Should we be talkative?
our $verbose = 0;

# Called at use() time.
sub import {
    my ($class, $test) = @_;
    load($test) if $test;
}

sub load {
    my ($test) = @_;

    my $json = read_file("t/$test.json");
    if ($json) {
        $data = decode_json($json);
    } else {
        croak "Failed to load mockup data for test $test\n";
    }
}

# Build and return a fake packet.
sub mockup {
    my ($name, $type, $class) = @_;
    my $d = $data->{$name}{$type}{$class};
    
    my $p = Net::DNS::Packet->new($name, $type, $class);
    
    foreach my $section (qw[answer additional authority]) {
        if ($d->{$section}) {
            foreach my $str (@{$d->{$section}}) {
                my $rr = Net::DNS::RR->new($str);
                $p->unique_push($section, $rr);
            }
        }
    }

    return $p;
}

1;

package Net::DNS::Resolver;

# And now let's fake up the DNS resolver.

use strict;
use warnings;
use 5.8.9;

# Tell Perl Net::DNS::Resolver is already loaded, so it doesn't pull in the real one later.
$INC{'Net/DNS/Resolver.pm'} = 'mocked';

our $AUTOLOAD;

sub new {
    return bless {};
}

sub send {
    my ($self, $name, $type, $class) = @_;
    if ($type eq 'IN' or $type eq 'CH') {
        ($class, $type) = ($type, $class);
    }
    print STDERR "send: $name $type $class\n" if $verbose;
    my $p = MockResolver::mockup($name, $type, $class);
    
    return $p;
}

sub persistent_tcp {}

sub cdflag {}

sub recurse {}

sub udp_timeout {}

sub tcp_timeout {}

sub retry {}

sub retrans {}

sub force_v4 {}

sub errorstring {''}

###
### Magic
###

sub DESTROY {
    # Det är vi, sågspånen
}

sub AUTOLOAD {
    print STDERR "needs to be mocked: $AUTOLOAD\n";
}

1;