#!/usr/bin/perl

use warnings;
use strict;
use Data::Dumper;

use File::Basename;
use YAML qw{LoadFile DumpFile};
use open qw(:std :utf8);

unless (@ARGV == 2 || @ARGV == 3) {
    print "usage: $0 locale_source to_file\n";
    print "or: $0 locale_source locale_id locale_name\n";
    exit(1);
}

my $blueprint = LoadFile($ARGV[0]);
my $replica;
my $to_file;

# When creating a new file
if(@ARGV == 3) {
	$replica = {
		locale_id => $ARGV[1],
		locale_name => $ARGV[2],
		messages => {}
	};
	$to_file = to_filename($ARGV[0])."/$ARGV[1].yaml";
}
# Load existing file
else {
	$replica = LoadFile($ARGV[1]);
	$to_file = $ARGV[1];
}

# Ensure that we have a hash
if(!defined($replica->{messages}) || ref($replica->{messages}) ne "HASH") {
	$replica->{messages} = {};
}

# Some simpler references
my $blueprint_msg = $blueprint->{messages};
my $replica_msg = $replica->{messages};

# Some information
print "From locale '$blueprint->{locale_id}' to '$replica->{locale_id}'\n";
print "($blueprint->{locale_name} to $replica->{locale_name})\n";
print "NOTE: To exit temporarily, write 'last'.\n";
print "Starts to iterate over messages\n\n";

# Iterate over the 'source', and add non-existing elements
foreach my $l (keys %{ $blueprint_msg }) {

	if(!defined($replica->{messages}{$l})) {
		my $ref = $blueprint_msg->{$l};
		my $input;
		print "Message: $l (args: $ref->{args})\n";

		# Format
		if(defined($ref->{format})) {
			print "Format: $ref->{format}\n";
			print "Input: ";
			chop ($input = <STDIN>);
			$ref->{format} = $input;
		}

		# Description
		if(defined($ref->{descr})) {
			print "Description: $ref->{descr}\n";
			print "Input: ";
			chop ($input = <STDIN>);
			$ref->{descr} = $input;
		}

		# Escape
		if($input =~ m/last|exit/) {
			last;
		} else {
			$replica_msg->{$l} = $ref;
		}
	}
}

# Write to file
print "\nDumping YAML to $ARGV[1]";
DumpFile($to_file, $replica);
