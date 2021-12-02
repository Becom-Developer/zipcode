package Zsearch::Search;
use parent 'Zsearch';
use Zsearch::Cond;
use strict;
use warnings;
use utf8;
use Data::Dumper;
use Text::CSV;
use Encode qw(encode decode);
use JSON::PP;
use FindBin;

sub cond { return Zsearch::Cond->new; }

sub csv {
    my ( $self, $cond ) = @_;
    my $path = $cond->{path};
    my $csv  = Text::CSV->new();
    open my $fh, "<:encoding(utf8)", $path or die "test.csv: $!";
    my @rows;
    while ( my $row = $csv->getline($fh) ) {
        if ( my $params = $self->cond->refined_search( $cond, $row ) ) {
            push @rows, $params;
        }
    }
    close $fh;
    return \@rows;
}

sub _index_path { return "$FindBin::RealBin/../tmp/index.json"; }

# インデックスを取得
sub _get_index {
    my ($self)     = @_;
    my $index_path = $self->_index_path;
    my $fh_index   = IO::File->new("< $index_path");
    die "not file: $!" if !$fh_index;
    my $line = decode( 'UTF-8', $fh_index->getline );
    $fh_index->close;
    return decode_json $line;
}

sub json {
    my ( $self, $cond ) = @_;
    warn 'json------';

    # code 指定がない場合はcsv検索へ
    my $code = $cond->{code};
    if ($code) {
        warn 'if------';

        my $index_hash = $self->_get_index;
        warn Dumper $index_hash;
        my $first       = substr( $code, 0, 1 );
        my $search_path = $index_hash->{code}->{$first};
        # warn $search_path;

        my $fh_json = IO::File->new("< $search_path");
        die "not file: $!" if !$fh_json;
        my $line = decode( 'UTF-8', $fh_json->getline );
        # warn $line;
        $fh_json->close;
        my $data = decode_json $line;

        warn Dumper decode_json $line;
        return;
    }
    return $self->csv($cond);
}

1;
