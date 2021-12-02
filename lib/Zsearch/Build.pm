package Zsearch::Build;
use parent 'Zsearch';
use strict;
use warnings;
use utf8;
use FindBin;
use JSON::PP;
use File::Path 'mkpath';
use Zsearch::Search;
use Data::Dumper;
use Encode qw(encode decode);

sub search { return Zsearch::Search->new; }

# 郵便番号全国版のファイル
sub _ken_all_path { return "$FindBin::RealBin/../csv/KEN_ALL.CSV"; }

# インデックスのファイル
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

# インデックスに保存
sub _save_index {
    my ( $self, $index_hash ) = @_;
    my $index_path = $self->_index_path;
    my $fh         = IO::File->new("> $index_path");
    die "not file: $!" if !$fh;
    $fh->print( encode_json $index_hash);
    $fh->close;
    return;
}

sub _zipcode {
    my ($self)  = @_;
    my @numbers = ( 0 .. 9 );
    my $total   = @numbers;
    print "start!! build zipcode\n";
    for my $number (@numbers) {
        print "Working $number/$total\n";

        # 保存するファイル名を決定
        my $file_path  = "$FindBin::RealBin/../tmp/$number.json";
        my $index_hash = $self->_get_index;

        # インデックスの登録状況確認
        if ( !exists $index_hash->{code}->{$number} ) {
            my $cond = +{
                code => $number,
                pref => undef,
                city => undef,
                town => undef,
                path => $self->_ken_all_path,
            };
            my $rows = $self->search->csv($cond);
            my $fh   = IO::File->new("> $file_path");
            die "not file: $!" if !$fh;
            print $fh encode_json $rows;
            $fh->close;

            # インデックス登録
            $index_hash->{code}->{$number} = $file_path;
            $self->_save_index($index_hash);
        }
    }
    return;
}

sub run {
    my ($self) = @_;
    my $tmp_path = "$FindBin::RealBin/../tmp";
    if ( !-d $tmp_path ) {
        mkpath($tmp_path);
    }

    # インデックスファイルの確認
    my $index_path = "$FindBin::RealBin/../tmp/index.json";
    if ( !-e $index_path ) {
        my $fh_json = IO::File->new("> $index_path");
        $fh_json->print(
            encode_json { code => {}, pref => {}, city => {}, town => {} } );
        $fh_json->close;
    }

    # インデックスデーターの作成
    # 郵便番号による
    $self->_zipcode;

    # 都道府県による
    # $self->index_pref;

    # 市町村による
    # $self->index_city;

    # 以下の住所
    # $self->index_town;

    return;
}

1;

__END__







    # 検索結果をまとめ

    # 該当するインデックス名を決定
    my $index = {
        code => {
            1 => $file_path,
        }
    };

    my $tmp_path   = "$FindBin::RealBin/../tmp";
    if ( !-d $tmp_path ) {
        mkpath($tmp_path);
    }

    # インデックスファイルに情報を保存
    # インデックス検索用のデーター、ファイル保存
    my $fh = IO::File->new("> $file_path");
    if ( defined $fh ) {
        print $fh encode_json $rows;
        $fh->close;
    }




    # インデックスファイル保存
    my $index_path = "$FindBin::RealBin/../tmp/index.json";
    my $fh = IO::File->new("> $index_path");
    if ( defined $fh ) {
        print $fh encode_json $index;
        $fh->close;
    }

    # my $index_path = "$FindBin::RealBin/../tmp/index.json";
    # my $tmp_path   = "$FindBin::RealBin/../tmp";
    # if ( !-d $tmp_path ) {
    #     mkpath($tmp_path);
    # }

    # # 目次のファイルを作成
    # my $fh   = IO::File->new("> $index_path");
    # my $hash = { foo => 'bar' };
    # if ( defined $fh ) {
    #     print $fh encode_json $hash;
    #     $fh->close;
    # }
