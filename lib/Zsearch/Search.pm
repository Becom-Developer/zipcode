package Zsearch::Search;
use parent 'Zsearch';
use Zsearch::Cond;
use strict;
use warnings;
use utf8;
use Data::Dumper;
use Text::CSV;
use FindBin;

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

    # build が実行されていない場合は csv 検索へ
    return $self->csv($cond) if !-e $self->index_path;

    # 指定による csv 検索実行
    return $self->csv($cond) if $cond->{mode} eq 'csv';

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

    # 全ての json ファイルを連続で検索してみる
    return $self->_all_json_file($cond);

    # return $self->csv($cond);
}

# 全ての json ファイルを連続で検索
sub _all_json_file {
    my ( $self, $cond ) = @_;
    my @file_number = ( 0 .. 9 );
    my $count       = @file_number;
    my @rows;
    for my $number (@file_number) {
        print STDERR $count;
        print STDERR '->';
        $count -= 1;
        my $file_path = "$FindBin::RealBin/../tmp/$number.json";
        my $data_ref  = $self->get_json($file_path);
        for my $data ( @{$data_ref} ) {
            if ( my $params =
                $self->cond->refined_search( $cond, $data, 'json' ) )
            {
                push @rows, $params;
            }
        }
    }
    return \@rows;
}

1;
