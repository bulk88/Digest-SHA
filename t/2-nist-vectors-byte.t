# Test against SHA-1 Sample Vectors from NIST
#
#	ref: http://csrc.nist.gov/cryptval/shs.html
#
# Uses files "nist/byte-messages.sha1" and "nist/byte-hashes.sha1"

use strict;
use integer;
use File::Basename qw(dirname);

# extract byte messages

my $i;
my @msgs;
my @hashes;
my @cnts;
my $bitstr;
my $bitval;
my $line;

my $datafile;

BEGIN {
	$datafile = dirname($0) . "/nist/byte-messages.sha1";
	open(F, $datafile);
	while (<F>) {
		last if (/Type 3/);
		$_ = substr($_, 0, length($_) - 2);
		next unless (/^[0-9^ ]/);
		$line .= $_;
		if (/\^$/) {
			$line = substr($line, 0, length($line) - 1);
			@cnts = split(' ', $line);
			$bitstr = "";
			$bitval = $cnts[1];
			for ($i = 0; $i < $cnts[0]; $i++) {
				$bitstr .= $bitval x $cnts[$i+2];
				$bitval = $bitval eq "1" ? "0" : "1";
			}
			push(@msgs, $bitstr);
			$line = "";
		}
	}
	close(F);

	$datafile = dirname($0) . "/nist/byte-hashes.sha1";
	open(F, $datafile);
	while (<F>) {
		$_ = substr($_, 0, length($_) - 2);
		next unless (/^[0-9A-F]/);
		if (/\^$/) {
			$_ = substr($_, 0, length($_) - 2);
			push(@hashes, $_);
		}
	}
	close(F);
}

use Test::More tests => scalar(@msgs);
use Digest::SHA;

my $ctx = Digest::SHA->new("sha1");
for (my $i = 0; $i < @msgs; $i++) {
	is(
		uc($ctx->add_bits($msgs[$i])->hexdigest),
		$hashes[$i],
		$hashes[$i]
	);
}
