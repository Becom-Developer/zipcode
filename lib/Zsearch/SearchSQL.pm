package Zsearch::SearchSQL;
use parent 'Zsearch';
use strict;
use warnings;
use utf8;

sub run {
    my ( $self, @args ) = @_;
    my $opts =
      +{ code => 'zipcode', pref => 'pref', city => 'city', town => 'town' };
    my $options = shift @args;
    my $params  = +{};
    my $cols    = [];
    while ( my ( $key, $val ) = each %{$opts} ) {
        if ( exists $options->{$key} ) {
            $params->{$val} = $options->{$key};
            push @{$cols}, $val;
        }
    }
    return $self->error->commit("Zipcode not specified correctly:")
      if !@{$cols};
    my $rows   = $self->rows( 'post', $cols, $params );
    my $count  = @{$rows};
    my $output = +{
        message => "検索件数: $count",
        result  => $rows,
    };
    return $output;
}

1;
