#!/usr/bin/perl
#
# $Id$

use warnings;
use strict;

printf("locale_name: English\n");
printf("locale_id: %s\n", "en");
printf("messages:\n");

while (<>) {
    chomp;

    if (/^"(.+)";(\d+)$/) {
	    printf(" %s:\n", $1);
        printf("  args: %d\n", $2);
        printf("  format: ~\n");
		printf("  descr: ~\n");
		next;
    }
}
