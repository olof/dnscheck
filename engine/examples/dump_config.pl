#!/usr/bin/env perl

# Script that dumps the effective configuration of DNSCheck in YAML format.

use DNSCheck;
use YAML::XS;

my %hash = %{DNSCheck->new->config};
delete $hash{loglevels};
delete $hash{root_zone_data};
delete $hash{locale};
delete $hash{hostname};

print Dump(\%hash);
