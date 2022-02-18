package Zsearch::Render;
use parent 'Zsearch';
use strict;
use warnings;
use utf8;
use Encode qw(encode decode);
use JSON::PP;

sub raw {
    my ( $self, @args ) = @_;
    print encode( 'UTF-8', shift @args );
    return;
}

sub simple {
    my ( $self, @args ) = @_;
    my $params = shift @args;
    my $text   = '';
    my $result = $params->{result};
    for my $row ( @{$result} ) {
        $text .= "$row->{zipcode} $row->{pref}$row->{city}$row->{town}\n";
    }
    $text .= $params->{message} . "\n";
    print encode( 'UTF-8', $text );
    return;
}

sub all_items_json {
    my ( $self, @args ) = @_;
    my $params = shift @args;
    print encode_json($params);
    print "\n";
    return;
}

1;
