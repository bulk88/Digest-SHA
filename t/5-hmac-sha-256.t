# HMAC-SHA-256 test vectors from draft-ietf-ipsec-ciph-sha-256-01.txt

use Test;
use strict;
use integer;
use Digest::SHA qw(hmac_sha256_hex);

BEGIN { plan tests => 10 }

my @data = (
	"abc",
	"abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq",
	"abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopqabcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq",
	"Hi There",
	"what do ya want for nothing?",
	chr(0xdd) x 50,
	chr(0xcd) x 50,
	"Test With Truncation",
	"Test Using Larger Than Block-Size Key - Hash Key First",
	"Test Using Larger Than Block-Size Key and Larger Than One Block-Size Data"
);

my $k1 = pack("H*", "0102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f20");
my $k2 = pack("H*", "0102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f202122232425");

my @key = (
	$k1,
	$k1,
	$k1,
	chr(0x0b) x 32,
	"Jefe",
	chr(0xaa) x 32,
	$k2,
	chr(0x0c) x 32,
	chr(0xaa) x 80,
	chr(0xaa) x 80
);

my @hmac256rsp = (
	"a21b1f5d4cf4f73a4dd939750f7a066a7f98cc131cb16a6692759021cfab8181",
	"104fdc1257328f08184ba73131c53caee698e36119421149ea8c712456697d30",
	"470305fc7e40fe34d3eeb3e773d95aab73acf0fd060447a5eb4595bf33a9d1a3",
	"198a607eb44bfbc69903a0f1cf2bbdc5ba0aa3f3d9ae3c1c7a3b1696a0b68cf7",
	"5bdcc146bf60754e6a042426089575c75a003f089d2739839dec58b964ec3843",
	"cdcb1220d1ecccea91e53aba3092f962e549fe6ce9ed7fdc43191fbde45c30b0",
	"d4633c17f6fb8d744c66dee0f8f074556ec4af55ef07998541468eb49bd2e917",
	"7546af01841fc09b1ab9c3749a5f1c17d4f589668a587b2700a9c97c1193cf42",
	"6953025ed96f0c09f80a96f78e6538dbe2e7b820e3dd970e7ddd39091b32352f",
	"6355ac22e890d0a3c8481a5ca4825bc884d3e7a1ff98a2fc2ac7d8e064c3b2e6"
);

# do the first one by hand to test multi-argument data feed

ok(hmac_sha256_hex("a", "b", "c", $k1), $hmac256rsp[0]);

for (my $i = 1; $i < @data; $i++) {
	ok(
		hmac_sha256_hex($data[$i], $key[$i]),
		$hmac256rsp[$i]
	);
}
