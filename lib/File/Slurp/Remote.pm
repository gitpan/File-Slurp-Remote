
use File::Slurp::Remote;

use strict;
use warnings;
use File::Slurp;
require Exporter;
use File::Slurp::Remote::BrokenDNS qw($myfqdn %fqdnify);
use Tie::Function::Examples qw(%q_shell);
use File::Slurp::Remote::SmartOpen;
use File::Temp qw(tempdir);

our @ISA = qw(Exporter);
our @EXPORT = (@File::Slurp::EXPORT, qw(write_remote_file read_remote_file));
my $tmpdir = tempdir(CLEANUP => 1);

sub write_remote_file
{
	my $host = shift;
	my $file = shift;

	if ($myfqdn eq $fqdnify{$host}) {
		write_file($file, @_);
	} else {
		write_file("$tmpdir/wrf$$", @_);
		my $scp = "scp -q -o StrictHostKeyChecking=no -o BatchMode=yes $tmpdir/wrf$$ $host:$q_shell{$file} 2> $tmpdir/e$$";
		system($scp);
		my $ec = $? >> 8;
		if ($ec) {
			my $e = read_file("$tmpdir/e$$");
			die "$scp: exit $ec\n$e";
		}
		unlink("$tmpdir/e$$");
		unlink("$tmpdir/wrf$$");
	}
}

sub read_remote_file
{
	my $host = shift;
	my $file = shift;

	if ($myfqdn eq $fqdnify{$host}) {
		if (wantarray) {
			return (read_file($file));
		} else {
			return scalar(read_file($file));
		}
	} else {
		my $fd;
		smartopen("$host:$file", $fd, "r");
		if (wantarray) {
			return <$fd>;
		} else {
			return join('', <$fd>);
		}
	}
}

1;

__END__

=head1 NAME

File::Slurp::Remote - read/write files on remote systems using ssh.

=head1 SYNOPSIS

 use File::Slurp::Remote;

 write_remote_file($host, $file, @contents);

 @lines = read_remote_file($host, $file);

 $whole_thing = read_remote_file($host, $file);

=head1 DESCRIPTION

This is similar to L<File::Slurp>, but it reads and writes files on
remote systems using C<ssh> to get there.

=head1 LICENSE

This package may be used and redistributed under the terms of either
the Artistic 2.0 or LGPL 2.1 license.

