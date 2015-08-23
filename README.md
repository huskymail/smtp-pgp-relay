# smtp-pgp-relay

Simple Mail Relay to Encrypt Mail With Public Key
=================================================

This relay listens on a port waiting for an e-mail. Then it searches for public key(s) corresponding to the recepient(s) in the SKS-API, encrypts the body of the e-mail and sends it to a mail server, as shown below:

```

			   PLAINTEXT BODY		FETCH/	  ENCRYPTED BODY
GMAIL/YAHOO  ------------------>	RELAY	------------------> MAIL SERVER
								
								  	  ^
								      |
								  	  | PUBLIC KEY SEARCH
								      |
								  	  v
							   
							       SKS-API
```

Example
------

### Mail sent from a regular client

```
Content-Transfer-Encoding: quoted-printable
Content-Type: text
MIME-Version: 1.0
X-Mailer: MIME::Lite 3.030 (F2.85; T2.11; A2.14; B3.14; Q3.13)
Date: Sun, 23 Aug 2015 09:29:46 -0300
From: superman@gmail.com
To: batman@huskymail.com
Subject: Relay test

[begin]
Husky Test
[end]
```

### Mail encrypted by the relay

```
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable
Content-Type: text
MIME-Version: 1.0
X-Mailer: MIME::Lite 3.030 (F2.85; T2.11; A2.14; B3.14; Q3.13)
Date: Sun, 23 Aug 2015 09:29:46 -0300
From: superman@gmail.com
To: batman@huskymail.com
Subject: Relay test

-----BEGIN PGP MESSAGE-----
Version: GnuPG v1

hQEMAzAFdoh1F/FaAQgAkLPJHydggdHU8YjZnBBuP50u63IQa0+1S3b2Iqk2EnXQ
ENmlH1XpSt/I3ixYRsRJa1fUi48wqPJ3MCQdZ8UChMg3Byhmj/hOyAmo17g/ZRDS
WzKofMC+rQ3yNZ7WmQEVusdaBrwHsWppi/pXcGxem6CSka/nqxYgEKAeZfdElQNS
nA8V8DcxYTVV6br8PdyhebWfnQnNL18Jy4+af87FOFR+8LKWQbp7rKg004A98sdZ
WXL3Pk6PdOPSdD5+VhGsqxIVUVNNH23d08YVrWRbrL0WjftkvD/huZtyupNjKnot
QixiiGZa586PT7SyCfNWiTIfJqhs+A6TK8BKRD6ULNJWASMPUfYMZMoy8pZI0nWF
vSRJsVH+1ulybA05ysRP6YfvMKfWGqd8b393lZ4CrAB9JOofo/0MmNyu/4JhmzWA
l53q2SQpa0HJI1DuK6P2DiGG0QqmDhM=
=Vm6y
----END PGP MESSAGE----
```

Installing and running
----------------------

Using cpanm:

```
cd smtp-pgp-relay/src
cpanm --installdeps .
GPGBIN='/usr/bin/gpg' SKS_API_ENDPOINT='http://sks.example.org:8080/' PORT='25' perl smtp-pgp-relay2.pl

```

TODO
----

- Send encrypted mail to a mail server.




			

