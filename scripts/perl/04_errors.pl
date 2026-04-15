#!/usr/bin/env perl
# Error handling - check HTTP status, print friendly message on >= 400.
use strict;
use warnings;
use HTTP::Tiny;
use JSON::PP;

my $body = encode_json({
    model => 'apple-foundationmodel',
    input => 'apfel runs 100% on-device.',
});

my $res = HTTP::Tiny->new->request(
    POST => 'http://localhost:11434/v1/embeddings',
    { headers => { 'Content-Type' => 'application/json' }, content => $body }
);

if ($res->{status} >= 400) {
    my $msg = 'see response';
    my $err = eval { decode_json($res->{content}) };
    if ($err && ref $err eq 'HASH' && $err->{error}) {
        $msg = $err->{error}{message} // $msg;
    }
    print "Got expected error: HTTP $res->{status} - $msg\n";
} else {
    print "unexpected success: HTTP $res->{status}\n$res->{content}\n";
}
