use ExtUtils::MakeMaker;
use File::ShareDir::Install;

my @exefiles = ( 'apps/dnscheck', 'apps/dnscheck-preflight',
                 'apps/dnscheck-dispatcher', 'apps/dnscheck-zonediff',
                 'apps/dnscheck-12hourmailer', 'apps/dnscheck-hostsyntax',
                 'apps/dnscheck-dnssecmailer', );

install_share dist => 'locale';
install_share dist => 'config';

WriteMakefile(
    'NAME'         => 'DNSCheck',
    'AUTHOR'       => '.SE (The Internet Infrastructure Foundation) <dnscheck@iis.se>',
    'ABSTRACT'     => 'DNS Quality and Integrity Checker',
    'VERSION_FROM' => 'lib/DNSCheck.pm',
    'PREREQ_PM'    => {
        'Crypt::OpenSSL::Random'  => 0,
        'Date::Format'            => 0,
        'Date::Parse'             => 0,
        'Digest::BubbleBabble'    => 0,
        'Digest::SHA'             => 0,
        'IO::Socket::INET6'       => 2.51,
        'Net::DNS'                => 0.65,
        'Net::DNS::SEC'           => 0.16,
        'Net::IP'                 => 1.25,
        'Socket6'                 => 0.19,
        'YAML'                    => 0,
        'DBI'                     => 0,
        'DBD::mysql'              => 0,
        'Mail::RFC822::Address'   => 0,
        'Text::Template'          => 0,
        'MIME::Lite'              => 0,
        'JSON::XS'                => 0,
        'File::Slurp'             => 0,
        'File::ShareDir::Install' => 0,
        'File::ShareDir'          => 0,
        'Config::Any'             => 0,
    },
    'EXE_FILES' => \@exefiles,
    'NO_META'   => 1,
    'SIGN'      => 0,
);

sub MY::postamble {

    package MY;
    my $self = shift;
    my @ret = File::ShareDir::Install::postamble( $self );

    my $tmp = qq#
coverage:
	cover -delete
	HARNESS_PERL_SWITCHES=-MDevel::Cover=+ignore,Mock make test
	cover

#;
    push @ret, $tmp;

    return join "\n", @ret;
}
