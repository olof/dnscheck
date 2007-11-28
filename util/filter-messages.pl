#!/usr/bin/perl
#
# $Id$

use warnings;
use strict;

sub filter {
    my $buffer;
    my $line = 0;
    while (<STDIN>) {
        chomp;

        $line++;

        if (/^#/) {
            $buffer = undef;
            next;
        }

        if (/;\s*$/) {
            analyze($buffer);
            $buffer = undef;
        }

        $buffer .= $_;
    }
}

sub analyze {
    my $buffer = shift;

    if ($buffer =~
        /logger.*->(info|notice|warning|error|debug|critical)\((.*)\);/)
    {
        my @args = split(",", $2);

        my $tag = shift @args;
        my $num = $#args + 1;

        return unless ($tag =~ /:/);

        printf("INSERT INTO messages (tag,arguments) VALUES (%s,%d);\n",
            $tag, $num);
    }
}

filter();
