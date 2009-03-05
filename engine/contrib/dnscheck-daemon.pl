#!/usr/bin/perl
# interface derived from apps/dnscheck version 0.81
# run as:  dnscheck-daemon &
# clients: echo "overmeer.net" | netcat localhost 8888
#
# You can pass any of the options of the dnscheck script, like --help
#   echo "--help" | netcat localhost 8888

use warnings;
use strict;

use lib '0.81/engine';  #### somewhere else?
use DNSCheck;           #### the Swedish one!
use Sys::Syslog    qw/openlog syslog/;

### to be removed when LOCALE_DIR/POLICY_DIR are set correctly
chdir '0.81/engine';

#### configuration begin
my $LOCALE_DIR = '/share/dnscheck/locale';
my $POLICY_DIR = '/share/dnscheck';

my $user   = 'markov';
my $group  = 'users';
my $port   = 8888;

my $logfac = 'local0';
#### configuration end

openlog 'dnscheck-se', 'pid,ndelay', $logfac;
syslog info => "started on port %d, user %s, group %s"
  , $port, $user, $group;

DNSCheck::Daemon->run
  ( port  => $port
  , user  => $user
  , group => $group
  );

exit 0;

###
#### DNSCheck::Daemon
###

package DNSCheck::Daemon;
use base 'Net::Server::PreFork';

use warnings;
use strict;

use Getopt::Long   qw/GetOptions/;
use Pod::Usage     qw/pod2usage/;
use Sys::Syslog    qw/syslog/;
use Time::HiRes    qw/gettimeofday tv_interval/;

sub process_request
{   my $self = shift;
    my $line = '';

    open STDERR, ">&STDOUT";

    while($line !~ m/\n/)
    {   sysread STDIN, $line, 1024, (length $line ? -1 : 0);
    }
    $line =~ s/\r?\n.*$//;

    syslog info => "query: %s", $line;

    # simulate shell, escaping with \\ not understood
    @ARGV = ();
    while($line =~ m/\S/)
    {   $line =~ s/^\s*(?:\"([^"]*)\"|\'([^']*)\'|(\S+))//;
        push @ARGV, $+;
    }

    my ($help, $debug, $timeout, $raw) = (0,0,0,0);
    my ($disable_ipv4, $disable_ipv6, $disable_smtp) = (0,0,0);
    my $locale       = "locale/en.yaml";
    my $policy       = "policy.yaml";

    GetOptions
      ( 'help|?'       => \$help
      , 'timeout=i'    => \$timeout
      , 'raw'          => \$raw
      , 'debug+'       => \$debug
      , 'disable-ipv4' => \$disable_ipv4
      , 'disable-ipv6' => \$disable_ipv6
      , 'disable-smtp' => \$disable_smtp
      ) or pod2usage(2);
    pod2usage(1) if $help;

    my $zone = shift @ARGV;
    $zone or pod2usage(2);

    -f $locale
        or $locale = $LOCALE_DIR . "/en.yaml";

    -f $policy
        or $policy = $POLICY_DIR . "/policy.yaml";

    $locale = undef
        if $raw;

    my $check = DNSCheck->new
     ( { interactive  => 1
       , debug        => $debug
       , locale       => $locale
       , policy       => $policy
       , udp_timeout  => $timeout
       , tcp_timeout  => $timeout
       , disable_ipv4 => $disable_ipv4
       , disable_ipv6 => $disable_ipv6
       , disable_smtp => $disable_smtp
       } );

    my $start = [gettimeofday];

    eval { $check->zone($zone) };
    print "APPLICATION ERROR: $@\n" if $@;

    syslog info => "%.3fs to check zone %s%s", tv_interval($start), $zone
       , ($@ ? ' (APPL ERROR!)' : '');

    exit 0;  # kill this child
}

__END__

=head1 NAME

dnscheck-daemon - DNSCheck Tool daemon

=head1 SYNOPSIS

dnscheck [options] zone

Options:

 --help                brief help message
 --debug               enable debugging. use twice for dns packet dump.
 --disable-ipv4        disable IPv4 transport
 --disable-ipv6        disable IPv6 transport
 --disable-smtp        disable SMTP test, suitable if port 25 is filtered
 --raw                 raw log output, suitable for automatic processing
 --timeout=SECONDS     set UDP/TCP timeout

