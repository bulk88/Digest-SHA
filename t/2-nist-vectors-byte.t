# Test against SHA-1 Sample Vectors from NIST
#
#	ref: http://csrc.nist.gov/cryptval/shs.html
#
# Uses files "nist/byte-messages.sha1" and "nist/byte-hashes.sha1"

use Test;
use strict;
use integer;

use File::Basename qw(dirname);
use File::Spec;
use Digest::SHA;

my @hashes;

BEGIN {
	my $file = dirname($0) . "/nist/byte-hashes.sha1";
	my $datafile = File::Spec->canonpath($file);
	open(F, $datafile);
	binmode(F);
	while (<F>) {
		$_ = substr($_, 0, length($_) - 2);
		next unless (/^[0-9A-F]/);
		if (/\^$/) {
			$_ = substr($_, 0, length($_) - 2);
			push(@hashes, $_);
		}
	}
	close(F);
	plan tests => scalar(@hashes);
}

sub doType3 {
	my $hash;
	my $str = pack("B*", shift);
	my $ctx = Digest::SHA->new(1);
	for (my $j = 0; $j <= 99; $j++) {
		for (my $i = 1; $i <= 50000; $i++) {
			$str .= chr(0x00) x (int($j/4)+3);
			$str .= pack("N", $i);
			$str = $ctx->add($str)->digest;
		}
		ok(uc(unpack("H*", $str)), $hash = shift(@hashes));
	}
}

my @msgs;
my @cnts;
my $bitstr;
my $bitval;
my $line;
my $hash;
my $type3 = 0;
my $ctx = Digest::SHA->new(1);

my $file = dirname($0) . "/nist/byte-messages.sha1";
my $datafile = File::Spec->canonpath($file);
open(F, $datafile);
binmode(F);
while (<F>) {
	$type3 = 1 if (/Type 3/);
	$type3 = 0 if (/^<D/);
	$_ = substr($_, 0, length($_) - 2);
	next unless (/^[0-9^ ]/);
	$line .= $_;
	if (/\^$/) {
		$line = substr($line, 0, length($line) - 1);
		@cnts = split(' ', $line);
		$bitstr = "";
		$bitval = $cnts[1];
		for (my $i = 0; $i < $cnts[0]; $i++) {
			$bitstr .= $bitval x $cnts[$i+2];
			$bitval = $bitval eq "1" ? "0" : "1";
		}
		ok (
			uc($ctx->add(pack("B*", $bitstr))->hexdigest),
			$hash = shift(@hashes)
		) unless $type3;
		doType3($bitstr) if ($type3);
		$line = "";
	}
}
close(F);
