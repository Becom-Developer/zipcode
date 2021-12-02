package Zsearch;
use strict;
use warnings;
use utf8;
use FindBin;
use Encode qw(encode decode);
use JSON::PP;

sub new { return bless {}, shift; }

# インデックスのファイル
sub index_path { return "$FindBin::RealBin/../tmp/index.json"; }

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
