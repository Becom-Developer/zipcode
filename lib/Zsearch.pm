package Zsearch;
use strict;
use warnings;
use utf8;
use FindBin;
use JSON::PP;
use Zsearch::Error;
use Zsearch::Build;

sub new   { return bless {}, shift; }
sub error { Zsearch::Error->new; }
sub build { Zsearch::Build->new; }

sub db_file {
    my $db_file = 'zsearch.db';
    if ( $ENV{"ZSEARCH_MODE"} && ( $ENV{"ZSEARCH_MODE"} eq 'test' ) ) {
        $db_file = 'zsearch-test.db';
    }
    return $db_file;
}

# インデックスのファイル
sub index_path { return "$FindBin::RealBin/../tmp/index.json"; }

# csv 全国版ファイル
sub csv_all_path { return "$FindBin::RealBin/../csv/KEN_ALL.CSV"; }

# json 形式でファイル保存
sub save_json {
    my ( $self, $file_path, $data_ref ) = @_;
    my $fh = IO::File->new("> $file_path");
    die "not file: $!" if !$fh;
    my $json_octets = encode_json $data_ref;
    $fh->print($json_octets);
    $fh->close;
    return;
}

# json 形式のファイルを取得
sub get_json {
    my ( $self, $file_path ) = @_;
    my $fh = IO::File->new("< $file_path");
    die "not file: $!" if !$fh;
    my $data_ref = decode_json $fh->getline;
    $fh->close;
    return $data_ref;
}

1;

__END__
