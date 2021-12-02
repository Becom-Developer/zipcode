package Zsearch::Search;
use parent 'Zsearch';
use Zsearch::Cond;
use strict;
use warnings;
use utf8;
use Data::Dumper;
use Text::CSV;

sub cond { return Zsearch::Cond->new; }

sub csv {
    my ( $self, $cond ) = @_;
    my $path = $cond->{path};
    my $csv  = Text::CSV->new();
    my $fh   = IO::File->new( $path, "<:encoding(utf8)" );
    die "not file: $!" if !$fh;
    my @rows;
    while ( my $row = $csv->getline($fh) ) {
        if ( my $params = $self->cond->refined_search( $cond, $row ) ) {
            push @rows, $params;
        }
    }
    $fh->close;
    return \@rows;
}

sub json {
    my ( $self, $cond ) = @_;

    # code 指定がない場合はcsv検索へ
    my $code = $cond->{code};
    if ( $code ne '' ) {
        my $index_hash  = $self->get_json( $self->index_path );
        my $first       = substr( $code, 0, 1 );
        my $search_path = $index_hash->{code}->{$first};
        my $data_ref    = $self->get_json($search_path);
        my @rows;
        for my $data ( @{$data_ref} ) {
            if ( my $params =
                $self->cond->refined_search( $cond, $data, 'json' ) )
            {
                push @rows, $params;
            }
        }
        return \@rows;
    }
    return $self->csv($cond);
}

1;
