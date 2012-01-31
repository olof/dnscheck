#!/usr/bin/env perl

use strict;
use warnings;
use 5.8.9;

use Net::DNS;
use JSON::XS;

my $data = {};
my $res = Net::DNS::Resolver->new();

while (my $line = <>) {
    my ($name, $type, $class) = $line =~ m/^send: (\S+)\s+(\S+)\s+(\S+)$/;
    next unless $name;

    my $p = $res->send($name, $type, $class);
    
    if ($p) {
        foreach my $section (qw[answer authority additional]) {
            foreach my $rr ($p->$section) {
                my $tmp = sprintf("%s %s %s %s",$rr->name, $rr->class, $rr->type, $rr->rdatastr);
                push @{$data->{$name}{$type}{$class}{$section}}, $tmp;
            }
        }   
    }
}

print JSON::XS->new->pretty->encode($data);
print "\n";