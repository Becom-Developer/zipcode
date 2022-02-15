package Zsearch::Render;
use parent 'Zsearch';
use strict;
use warnings;
use utf8;
use Data::Dumper;
use Encode qw(encode decode);
use JSON::PP;

sub to_simple {
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

sub to_json {
    my ( $self, @args ) = @_;
    my $params = shift @args;
    print encode_json($params);
    print "\n";
    return;
}

sub stdout {
    my ( $self, $type, $rows ) = @_;
    if ( $type eq 'standard' ) {
        my $standard = $self->_standard($rows);
        print encode( 'UTF-8', $standard->{output} );
        print encode( 'UTF-8', "検索件数: $standard->{count}" );
        print "\n";
        return;
    }
    if ( $type eq 'json' ) {
        my $json = $self->_json($rows);
        print encode_json $json->{output};
        print "\n";
        return;
    }
    return;
}

sub _standard {
    my ( $self, $rows ) = @_;
    my $output = '';
    for my $row ( @{$rows} ) {
        $output .= "$row->{zipcode} $row->{pref}$row->{city}$row->{town}\n";
    }
    my $count = @{$rows};
    return +{ count => $count, output => $output };
}

sub _json {
    my ( $self, $rows ) = @_;
    my $output = [];
    for my $row ( @{$rows} ) {
        push @{$output},
          +{
            zipcode => $row->{zipcode},
            pref    => $row->{pref},
            city    => $row->{city},
            town    => $row->{town},
          };
    }
    my $count = @{$rows};
    return +{ count => $count, output => $output };
}

1;
