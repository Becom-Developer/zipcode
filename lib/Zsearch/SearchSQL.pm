package Zsearch::SearchSQL;
use parent 'Zsearch';
use strict;
use warnings;
use utf8;

# sub run {
#     my ( $self, @args ) = @_;
#     my $options = shift @args;
#     return $self->error->commit("No arguments") if !$options;
#     return $self->_run($options)                if $options->{method} eq 'like';
#     return $self->error->commit(
#         "Method not specified correctly: $options->{method}");
# }

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
            if ( $options->{$key} ne '' ) {
                push @{$cols}, $val;
            }
        }
    }
    return $self->error->commit("Zipcode not specified correctly:")
      if !@{$cols};
    my $rows   = $self->valid_search( 'post', $params, { cond => 'LIKE%' } );
    my $count  = @{$rows};
    my $output = +{
        message => "検索件数: $count",
        result  => $rows,
    };
    return $output;
}

1;
