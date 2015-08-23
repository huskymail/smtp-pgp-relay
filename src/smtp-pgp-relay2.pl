#!/usr/bin/env perl
###############################################################################
#
# Simple SMTP Relay (encrypts body mail if destination public keys is available on SKS API)
#
# Example of use:
# GPGBIN='/usr/bin/gpg' SKS_API_ENDPOINT='http://sks.example.org:8080/' PORT='25' perl smtp-pgp-relay2.pl
#
###############################################################################

use Carp;
use Net::SMTP::Server;
use Net::SMTP::Server::Client;
use Net::SMTP::Server::Relay;
use HTTP::Tiny;
use JSON;
use Crypt::GPG;
use Email::Simple;

#  Ckecking environment variables
if (defined $ENV{PORT} && $ENV{PORT} =~ /\d+/smx && $ENV{PORT} > 0 && $ENV{PORT} < 65536) {
	print "Port check ok ($ENV{PORT})\n";
} else {
	croak("Port check failed ($ENV{PORT})\n");
}
if (defined $ENV{SKS_API_ENDPOINT}) {
	my $response = HTTP::Tiny->new->get($ENV{SKS_API_ENDPOINT}.'status');
	if (! $response->{success}) {
		croak("SKSAPI check failed ($ENV{SKS_API_ENDPOINT})\n");
	}
} else {
	croak("SKSAPI check failed ($ENV{SKS_API_ENDPOINT})\n");
}



my $server = Net::SMTP::Server->new('0.0.0.0', $ENV{PORT}) || croak("Unable to handle client connection: $!\n");

while($conn = $server->accept()) {
	# We can perform all sorts of checks here for spammers, ACLs,
	# and other useful stuff to check on a connection.

	# Handle the client's connection and spawn off a new parser.
	# This can/should be a fork() or a new thread,
	# but for simplicity...
	my $client = new Net::SMTP::Server::Client($conn) || croak("Unable to handle client connection: $!\n");

	# Process the client.  This command will block until
	# the connecting client completes the SMTP transaction.
	$client->process || next;

	foreach my $rcpt (@{$client->{TO}}) {

		#  Verifies if the e-mail is in the format 'Name <name@example.org>'
		if ($rcpt =~ /^<*(.*)>$/smx ) {
			$rcpt = $1;
		}

		my $response = HTTP::Tiny->new->get($ENV{SKS_API_ENDPOINT}.'mail/'.$rcpt);

		# Encrypts the e-mail if corresponding key is found on sks-api
		if ($response->{success}) {

			#  Saving response in perl structure
			$json = from_json( $response->{content}, { utf8  => 1 } );

			#  Gets the newest key ($created_time[-1])
			my @created_time;
			foreach my $keys (@{$json->{data}}) {
				push  @created_time,$keys->{created};
			}
			@created_time = sort { $a <=> $b } @created_time;

			#  Gets the newest key
			my $public_key;
			my $public_key_id;
			foreach my $keys (@{$json->{data}}) {
				if ($keys->{created} == $created_time[-1]) {
					$public_key = $keys->{public_key};
					$public_key_id = $keys->{id};
				}
			}

			#  Gets only the body of the e-mail ($email->body)
			my $email = Email::Simple->new($client->{MSG});

			#  Adds the public key to the keychain and encrypts the body of the e-mail	
			my $gpg = Crypt::GPG->new();
			$gpg->encryptsafe(0);
			$gpg->gpgbin($ENV{GPGBIN});
			$gpg->addkey($public_key);
			my $ciphertext = $gpg->encrypt($email->body,$public_key_id);
			#  Removing string of comment
			$ciphertext =~ s/Comment: Crypt::GPG\s+[\w\d\.]+\n//;

			#  Generating a new cryptographic body
			my $body = $email->header_obj->as_string."\n".$ciphertext;

			my $relay = Net::SMTP::Server::Relay->new($client->{FROM},[$rcpt],$body);

			# TODO: send mail to configured server
		} else {
			my $relay = Net::SMTP::Server::Relay->new($client->{FROM},[$rcpt],$client->{MSG});
			# TODO: send mail to configured server
		}
	}
}