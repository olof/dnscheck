#!/usr/bin/perl
#
# $Id: $
#
# Copyright (c) 2007 .SE (The Internet Infrastructure Foundation).
#                    All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
# IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY
# DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
# GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER
# IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
# OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN
# IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
######################################################################

use strict;
use warnings;

use DNSCheck;
use Net::SMTP;
use DBI;

my $reggie;
my $dc;

sub setup {
    $dc     = DNSCheck->new;
    $reggie = get_reggie_dbh($dc->config->get("reggie"));
}

sub get_reggie_dbh {
    my $conf = shift;

    my $dsn = sprintf("DBI:mysql:database=%s;hostname=%s;port=%s",
        $conf->{"database"}, $conf->{"host"}, $conf->{"port"});

    my $dbh =
      DBI->connect($dsn, $conf->{"user"}, $conf->{"password"},
        { RaiseError => 1, AutoCommit => 1 });
    die "Failed to connect to Reggie: " . $DBI::errstr unless defined($dbh);

    return $dbh;

}

sub generate_mail_text_for_registrar {
    my $name = shift;
    my $ref  = shift;

    my $m = "";

    $m .= "From: Efterkontrollen\n";
    $m .= "To: " . $ref->{mail} . "\n";
    $m .= "Subject: Testresultat för era domäner\n";
    $m .= "\n";
    foreach my $d (keys %{ $ref->{domains} }) {
        my $t = $ref->{domains}{$d};
        $m .= sprintf(
            "%s: %d critical problems and %d errors. Test started at %s.\n",
            $d, $t->{count_critical}, $t->{count_error}, $t->{begin});
    }

    $m .= "\n";
    return $m;
}

sub get_registrar_info {
    my $domain = shift;

    my ($email3, $display_name) = $reggie->selectrow_array(
        q[
        select EMAIL3, DISPLAY_NAME
        from REGISTRARS, USERS, DOMAINS
        where DOMAINS.NAME = ? and DOMAINS.CLID = USERS.USER_ID and DOMAINS.CLID = REGISTRARS.EPP_USER_ID
        ], undef, $domain
    );

    return ($email3, $display_name);
}

sub aggregate_registrar_info {
    my @domains = @_;
    my %res;

    foreach my $d (@domains) {
        my ($mail, $name) = get_registrar_info($d);
        $mail = 'no.email.given@iis.se'    unless defined($mail);
        $name = "Unknown registrar for $d" unless defined($name);
        $res{$name}{mail} = $mail;
        $res{$name}{domains}{$d} = get_test_results($d);
    }
    return %res;
}

sub domains_tested_last_day {
    my $aref = $dc->dbh->selectall_arrayref(
        q[
        SELECT DISTINCT domain FROM tests WHERE begin > subtime(now(),'24:00:00') AND (count_critical + count_error) > 0
        ]
    );
    return map { $_->[0] } @$aref;
}

sub get_test_results {
    my $domain = shift;

    my $test = $dc->dbh->selectrow_hashref(
        q[
        SELECT * FROM tests WHERE domain = ? ORDER BY id DESC LIMIT 1
        ], undef, $domain
    );
    die "Domain $domain not tested!\n" unless $test;
    return $test;
}

sub send_mail {
    my $address = shift;
    my $body    = shift;
    my $conf    = $dc->config->get("12hour");

    my $smtphost = $conf->{smtphost};
    my $smtp     = Net::SMTP->new($smtphost)
      or die "Failed to connect to SMTP host $smtphost";

    $smtp->mail($conf->{from});
    $smtp->to($address);
    $smtp->data($body);
    $smtp->quit;
}

setup();
my %data = aggregate_registrar_info(domains_tested_last_day());

foreach my $reg (keys %data) {
    if ($dc->config->get("12hour")->{debug}) {
        print "<$reg>\n\n";
        print generate_mail_text_for_registrar($reg, $data{$reg});
    } else {
        send_mail($data{$reg}{mail}, generate_mail_text_for_registrar($reg, $data{$reg}));
    }
}
