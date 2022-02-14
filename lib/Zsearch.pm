package Zsearch;
use strict;
use warnings;
use utf8;
use FindBin;
use JSON::PP;
use Zsearch::Error;
use Zsearch::Build;
use File::Spec;
use DBI;
use Time::Piece;
use Data::Dumper;
sub new        { return bless {}, shift; }
sub error      { Zsearch::Error->new; }
sub build      { Zsearch::Build->new; }
sub time_stamp { return localtime->datetime( 'T' => ' ' ); }

sub db_file {
    my $db_file = 'zsearch.db';
    if ( $ENV{"ZSEARCH_MODE"} && ( $ENV{"ZSEARCH_MODE"} eq 'test' ) ) {
        $db_file = 'zsearch-test.db';
    }
    return $db_file;
}

sub build_dbh {
    my ( $self, @args ) = @_;
    my $db_file = $self->db_file;
    my $db   = File::Spec->catfile( "$FindBin::RealBin", '..', 'db', $db_file );
    my $attr = +{
        RaiseError     => 1,
        AutoCommit     => 1,
        sqlite_unicode => 1,
    };
    my $dbh = DBI->connect( "dbi:SQLite:dbname=$db", "", "", $attr );
    return $dbh;
}

# インデックスのファイル
sub index_path { return "$FindBin::RealBin/../tmp/index.json"; }

# csv 全国版ファイル
sub csv_all_path { return "$FindBin::RealBin/../csv/KEN_ALL.CSV"; }

# csv 福岡
sub csv_fukuoka_path { return "$FindBin::RealBin/../csv/40FUKUOK.CSV"; }

# データベース構築用csvファイル
sub insert_csv {
    my ($self) = @_;
    my $file = $self->csv_all_path();
    if ( $ENV{"ZSEARCH_MODE"} && ( $ENV{"ZSEARCH_MODE"} eq 'test' ) ) {
        $file = $self->csv_fukuoka_path();
    }
    return $file;
}

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
