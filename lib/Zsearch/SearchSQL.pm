package Zsearch::SearchSQL;
use strict;
use warnings;
use utf8;
use Pickup;
use Zsearch::DB;
sub new          { bless {}, shift; }
sub error        { Pickup->new->error; }
sub render       { Pickup->new->render; }
sub DB           { Zsearch::DB->new; }
sub valid_search { my ( $self, @args ) = @_; return DB->valid_search(@args); }

sub zipcode_version {
    my ( $self, @args ) = @_;
    return DB->zipcode_version(@args);
}

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
    my $options  = shift @args;
    my $params   = $options->{params};
    my $q_params = +{};
    my $cols     = [];
    for my $key ( 'zipcode', 'pref', 'city', 'town' ) {
        next if !exists $params->{$key};
        $q_params->{$key} = $params->{$key};
        if ( $params->{$key} ne '' ) {
            push @{$cols}, $key;
        }
    }
    return $self->error->commit("Zipcode not specified correctly:")
      if !@{$cols};
    my $rows = $self->valid_search( 'post', $q_params, { cond => 'LIKE%' } );
    if ( !$rows ) {
        $rows = [];
    }
    if ( ( exists $params->{output} ) && ( $params->{output} eq 'list' ) ) {
        for my $row ( @{$rows} ) {
            $row = {
                id      => $row->{id},
                zipcode => $row->{zipcode},
            };
        }
    }
    my $count  = @{$rows};
    my $output = +{
        message => "検索件数: $count",
        data    => $rows,
        version => $self->zipcode_version(),
        count   => $count,
    };
    return $output;
}

1;
