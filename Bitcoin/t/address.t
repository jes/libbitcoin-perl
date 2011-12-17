use strict;
use Test;

BEGIN { plan tests => 8 }

use Bitcoin::Address;

use constant KEYS => [

    [ <<EOF
-----BEGIN PUBLIC KEY-----
MFYwEAYHKoZIzj0CAQYFK4EEAAoDQgAECTD4KyRWycM+6PDTg3p6G8EwBktLMItu
2CqUIA7vBDX+KnjtZHpF0lUMApTGVHr0900glvWOjEKraB57wlle2Q==
-----END PUBLIC KEY-----
EOF
	, '1QAVk6rZ8Tzj6665X3v1yPGfKwNHFjGV4y'
    ],

    [ <<EOF
-----BEGIN PUBLIC KEY-----
MFYwEAYHKoZIzj0CAQYFK4EEAAoDQgAEg/kE+E72DbB6yuHh8ge1FperHOHDahjP
zuXEz1/JZ00Qt3wJQQwUC0W97INs0AnqUgxwMyO5JL1TKOf1vP0Zbw==
-----END PUBLIC KEY-----
EOF
	, '15gR9zUv3YW6DRf9fVvPXC7x9csPM8QcTg'
    ],

    [ <<EOF
-----BEGIN PUBLIC KEY-----
MFYwEAYHKoZIzj0CAQYFK4EEAAoDQgAE6TS3lvFdqdU2aUMvj08Y8RHJ4xPXCK5C
NNstfRamvKMZSlFGIlKaxEg7Cux2KzbGpUbDsyR92wGRqWjj2cSzNQ==
-----END PUBLIC KEY-----
EOF
	, '1HPXLeY56LaB91HHFGyHq4F2cCmfFmmMLh'
    ],

];

ok( Bitcoin::Address->new('1DxH3bjYeCKbSKvVEsXQUBjsTcxagmWjHy')->toHex, '008e15c7e4ca858c3f412461bee5d472b0b6c362a5b6673b28');
my $addr = Bitcoin::Address->new(KEYS->[0][0]);
ok ( $$addr, qr/^1/, "generated address does not start with 1" );

ok( Bitcoin::Address->new($$_[0])->toBase58, $$_[1] ) for @{+KEYS};

eval { Bitcoin::Address->new('1DxFAKEFAKEFAKEFAKEFAKEFAKEagmWjHy') };
ok( $@, qr/wrong checksum/i, "failed to detect a wrong checksum" );

my $addr1 = Bitcoin::Address->new(KEYS->[0][0], 1);

ok( $addr1->version, 1 );
ok( $addr1->value, $addr->value );

my $addr2 = '1QAVk6rZ8Tzj6665X3v1yPGfKwNHFjGV4y';
bless \$addr2, 'Bitcoin::Address';
ok( (\$addr2)->value, $addr->value);
