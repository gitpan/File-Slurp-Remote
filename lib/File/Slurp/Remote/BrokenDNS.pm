
package File::Slurp::Remote::BrokenDNS;

use strict;
use warnings;
use Tie::Function::Examples;
use Socket;
require Exporter;

our @ISA = qw(Exporter);
our @EXPORT_OK = qw($myfqdn %fqdnify);

our $myfqdn = `hostname`;
chomp($myfqdn);

my %cache;

tie our %fqdnify, 'Tie::Function::Examples', 
	sub {
		my ($host) = @_;
		return $cache{$host} if $cache{$host};
		my $hn = `ssh -o StrictHostKeyChecking=no $host -n hostname`;
		chomp($hn);
		return $cache{$host} = $hn;
	};

1;

__END__

This is how this should be written if we had working DNS.

use Sys::Hostname::FQDN qw(fqdn);
our $myfqdn = fqdn();

tie our %fqdnify, 'Tie::Function::Examples', 
	sub {
		my ($host) = @_;
		my $iaddr = gethostbyname($host);
		return $host unless defined $iaddr;
		my $name = gethostbyaddr($iaddr, AF_INET);
		return $host unless defined $name;
		return $name;
	};

1;

=head1 NAME

File::Slurp::Remote::BrokenDNS - map hostnames to the output of `hostname`

=head1 SYNOPSIS

 use File::Slurp::Remote::BrokenDNS qw($myfqdn %fqdnify);

 print "alias for me\n" if $myfqdn eq $fqdnify{$host2};

=head1 DESCRIPTION

This module is for the situation where your DNS is broken, but ssh works,
so you can figure out if two hostnames refer to the same system only by
running the C<hostname> command on both and seeing if it's the same.

=head1 FUTURE WORK

What would make this a lot better would be some way to switch between an
implementation that used DNS and this implementation that uses ssh `hostname`.
Ideas?

=head1 LICENSE

This package may be used and redistributed under the terms of either
the Artistic 2.0 or LGPL 2.1 license.



