#!/usr/bin/perl
# Perlectrum, an Electrum client in Perl :)
#
# For more info about Electrum and its original client/server in Python,
# see git://gitorious.org/electrum/electrum.py
#
# For general info about bitcoin, see http://www.bitcoin.org
#
package Bitcoin::Electrum::Client;
require Exporter;
@ISA = qw(Exporter);
@EXPORT_OK = qw(gap_limit host port fee);

use strict;
use warnings;

# Dependencies
#
use Bitcoin;
use Bitcoin::Base58;
use Bitcoin::Address;
use Bitcoin::Electrum qw(SERVER_LIST DEFAULT_PORT);
use Bitcoin::Electrum::Wallet;
use Digest::SHA qw(sha256 sha512);

# Package public variables and constants
#
our $gap_limit = 5;			
our ($host, $port) = ( SERVER_LIST->[0], DEFAULT_PORT );
our $fee = 0.005;

# package private variables
#
my $wallet;

my $message = '';
my $tx_history = {};
my $rtime = 0;

# subroutines

sub PrivKeyToSecret { return substr shift, 9, 32 }
sub int_to_hex {
    use bigint;
    my $i = shift;
    my $len = shift || 64; # nibbles
    $i += 16**$len;
    $i->as_hex =~ s/0x1//r;
}
sub filter { join '', map { s/.*\t//r } split "\n", shift }

sub raw_tx {
    my ($input, $output) = @_;
    my $for_sig = shift;

    my $s;
    $s = sprintf "%s\t\t\t%8x\n".  "%s\t%x\n",
    'version:',			1,
    'number of inputs:',	scalar(@$input);

    my $script;
    my $i = 0;
    for (@$input) {
	my (%p, $pubkey, $sig);
	($p{hash}, $p{index}, $p{script}, $pubkey, $sig) = @$_[2..6];
	$sig .= chr(1);
	$pubkey = chr(4) . $pubkey;

	$script =
	$for_sig && $for_sig == $i++ ? $p{script} :
	!$for_sig ? sprintf '%2x%x'x 2 ."\n", map { length($_), $_ } $sig, $pubkey :
	'';

	$s .= sprintf "%s\t%x\n". "%s\t%8x\n". "%s\t%2x\n".  "%s\n". "%s\t\t%s\n",
	"previous hash:",	unpack('H*', reverse pack 'H*', $p{hash}),
	"previous index:",	$p{index},
	"script length:",	length(filter $script)/2,
	$script,
	"sequence:",		'ff' x 4;
    }
    $s .= sprintf "%x			number of outputs\n", scalar @$output;
    for (@$output) {
	my ($addr, $amount) = @$_;
	$s .= sprintf "%16x		amount: %d\n", $amount, $amount;
	$script = '76a9';
	$script .= '14';
	$script .= substr Bitcoin::Address::new($addr)->toHex, 2, -8;
	$script .= '88ac';
	$s .= sprintf "%x		script length\n", length(filter $script)/2;
	$s .= sprintf "%s		script", $script;
    }
    $s .= sprintf '%8x', 0; 		# lock time (ndt: ???) 
    $s .= sprintf '%8x', 1 unless $for_sig;

    return $s;
}


1;

__END__

=head1 TITLE

Bitcoin::Electrum::Client

=head1 SYNOPSIS

    use Bitcoin::Electrum::Client qw(host fee port);

    $fee = 0.01;
    $host = 'perlectrum.org';

    Bitcoin::Electrum::Client::load_wallet('/optionnal/path/to/your/wallet');
    Bitcoin::Electrum::Client::run();

=head1 DESCRIPTION

This module implements an Electrum's client.  It is not supposed to be used
directly.  It is rather a library designed to be used by other programs such as
GUIs.

=head1 AUTHOR

L Grondin <grondilu@yahoo.fr>

=head1 COPYRIGHT AND LICENSE

Copyright 2011, Lucien Grondin.  All rights reserved.  

This library is free software; you can redistribute it and/or modify it under 
the same terms as Perl itself (L<perlgpl>, L<perlartistic>).

=cut
