use Test;
use strict;
use integer;
use File::Basename qw(dirname);
use File::Spec;
use Digest::SHA;

BEGIN { plan tests => 2 }

# test OO methods using first two SHA-256 vectors from NIST

my $temp = dirname($0) . "/oo.tmp";
my $file = File::Spec->canonpath($temp);
open(FILE, ">$file");
binmode(FILE);
print FILE "bcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq";
close(FILE);

my @vecs = (
	"ungWv48Bz+pBQUDeXa4iI7ADYaOWF3qctBD/YfIAFa0",
	"248d6a61d20638b8e5c026930c3e6039a33ce45964ff2167f6ecedd419db06c1"
);

my $ctx = Digest::SHA->new()->reset("SHA-256")->new();
$ctx->add_bits("a", 5)->add_bits("001");

my $rsp = shift(@vecs);
ok($ctx->clone->add("b", "c")->b64digest, $rsp);

$rsp = shift(@vecs);
open(FILE, "<$file");
binmode(FILE);
ok($ctx->addfile(*FILE)->hexdigest, $rsp);
close(FILE);
unlink($file);
