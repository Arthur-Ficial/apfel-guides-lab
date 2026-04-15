#!/usr/bin/env perl
# Tool calling - define tool, model calls it, return result, model replies.
use strict;
use warnings;
use HTTP::Tiny;
use JSON::PP;
binmode STDOUT, ':encoding(UTF-8)';

my $TOOLS = [{
    type     => 'function',
    function => {
        name        => 'get_weather',
        description => 'Get the current temperature in Celsius for a city.',
        parameters  => {
            type       => 'object',
            properties => { city => { type => 'string', description => 'City name' } },
            required   => ['city'],
        },
    },
}];

sub get_weather {
    my %args = @_;
    my %fake = (Vienna => 14, Cupertino => 19, Tokyo => 11);
    my $city = $args{city} // 'Vienna';
    return encode_json({ city => $city, temp_c => $fake{$city} // 15 });
}

sub post_chat {
    my ($body) = @_;
    my $res = HTTP::Tiny->new->request(
        POST => 'http://localhost:11434/v1/chat/completions',
        { headers => { 'Content-Type' => 'application/json' }, content => encode_json($body) }
    );
    die "HTTP $res->{status}: $res->{content}\n" unless $res->{success};
    return decode_json($res->{content});
}

my @messages = ({ role => 'user', content => 'What is the temperature in Vienna right now?' });

my $first = post_chat({
    model      => 'apple-foundationmodel',
    messages   => \@messages,
    tools      => $TOOLS,
    max_tokens => 256,
});

my $msg = $first->{choices}[0]{message};
push @messages, $msg;

if ($msg->{tool_calls} && @{ $msg->{tool_calls} }) {
    for my $call (@{ $msg->{tool_calls} }) {
        my $args = decode_json($call->{function}{arguments});
        my $result = get_weather(%$args);
        push @messages, {
            role           => 'tool',
            tool_call_id   => $call->{id},
            content        => $result,
        };
    }
    my $final = post_chat({
        model      => 'apple-foundationmodel',
        messages   => \@messages,
        max_tokens => 120,
    });
    my $text = $final->{choices}[0]{message}{content} // '';
    $text =~ s/^\s+|\s+$//g;
    print "$text\n";
} else {
    my $text = $msg->{content} // '';
    $text =~ s/^\s+|\s+$//g;
    print "$text\n";
}
