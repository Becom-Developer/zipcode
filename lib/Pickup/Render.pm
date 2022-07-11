package Pickup::Render;
use parent 'Pickup::Base';
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
    my $data   = $params->{data};
    for my $row ( @{$data} ) {
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
