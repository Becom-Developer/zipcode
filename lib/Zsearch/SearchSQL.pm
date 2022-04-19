package Zsearch::SearchSQL;
use parent 'Zsearch';
use strict;
use warnings;
use utf8;

sub run {
    my ( $self, @args ) = @_;
    my $options = shift @args;
    return $self->error->commit("No arguments") if !$options;
    return $self->_like($options)               if $options->{method} eq 'like';
    return $self->error->commit(
        "Method not specified correctly: $options->{method}");
}

sub _like {
    my ( $self, @args ) = @_;
    my $options = shift @args;
    my $params  = $options->{params};
    my $opts =
      +{ code => 'zipcode', pref => 'pref', city => 'city', town => 'town' };
    my $q_params = +{};
    my $cols     = [];
    while ( my ( $key, $val ) = each %{$opts} ) {
        if ( exists $params->{$key} ) {
            $q_params->{$val} = $params->{$key};
            if ( $params->{$key} ne '' ) {
                push @{$cols}, $val;
            }
        }
    }
    return $self->error->commit("Zipcode not specified correctly:")
      if !@{$cols};
    my $rows   = $self->valid_search( 'post', $q_params, { cond => 'LIKE%' } );
    if (!$rows) {
        $rows = [];
    }
    my $count  = @{$rows};
    my $output = +{
        message => "検索件数: $count",
        result  => $rows,
    };
    return $output;
}

1;
