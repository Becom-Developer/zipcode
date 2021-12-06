package Zsearch::Build;
use parent 'Zsearch';
use strict;
use warnings;
use utf8;
use FindBin;
use File::Path 'mkpath';
use Zsearch::Search;
use Data::Dumper;

sub search { return Zsearch::Search->new; }

# 郵便番号全国版のファイル
sub _ken_all_path { return "$FindBin::RealBin/../csv/KEN_ALL.CSV"; }

sub _zipcode {
    my ($self)  = @_;
    my @numbers = ( 0 .. 9 );
    my $total   = @numbers;
    print "start!! build zipcode\n";
    for my $number (@numbers) {
        print "Working $number/$total\n";

        # 保存するファイル名を決定
        my $file_path  = "$FindBin::RealBin/../tmp/$number.json";
        my $index_hash = $self->get_json( $self->index_path );

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
            $self->save_json( $file_path, $rows );

            # インデックス登録
            $index_hash->{code}->{$number} = $file_path;
            $self->save_json( $self->index_path, $index_hash );
        }
    }
    return;
}

sub _100_divisions {
    warn '_100_divisions-----1';
    my ($self)  = @_;
    my @numbers = ( 0 .. 99 );

    for my $num (@numbers){
        # warn $num;
        my $str = sprintf("%02d", $num);
        warn $str;

        # 保存するファイル名を決定
        my $file_path  = "$FindBin::RealBin/../tmp/100/$str.json";
        warn $file_path;

            my $cond = +{
                code => $str,
                pref => undef,
                city => undef,
                town => undef,
                path => $self->_ken_all_path,
            };
            my $rows = $self->search->csv($cond);
            $self->save_json( $file_path, $rows );

    }


    # my $total   = @numbers;
    # print "start!! build zipcode\n";
    # for my $number (@numbers) {
    #     print "Working $number/$total\n";

    #     # 保存するファイル名を決定
    #     my $file_path  = "$FindBin::RealBin/../tmp/$number.json";
    #     my $index_hash = $self->get_json( $self->index_path );

    #     # インデックスの登録状況確認
    #     if ( !exists $index_hash->{code}->{$number} ) {
    #         my $cond = +{
    #             code => $number,
    #             pref => undef,
    #             city => undef,
    #             town => undef,
    #             path => $self->_ken_all_path,
    #         };
    #         my $rows = $self->search->csv($cond);
    #         $self->save_json( $file_path, $rows );

    #         # インデックス登録
    #         $index_hash->{code}->{$number} = $file_path;
    #         $self->save_json( $self->index_path, $index_hash );
    #     }
    # }
    return;
}

sub run {
    my ($self) = @_;
    my $tmp_path = "$FindBin::RealBin/../tmp/100/";
    if ( !-d $tmp_path ) {
        mkpath($tmp_path);
    }

    # インデックスファイルの確認
    if ( !-e $self->index_path ) {
        my $index_hash = +{ code => {}, pref => {}, city => {}, town => {} };
        $self->save_json( $self->index_path, $index_hash );
    }

    # インデックスデーターの作成
    # 郵便番号による
    # $self->_zipcode;

    # 都道府県による
    # $self->index_pref;

    # 市町村による
    # $self->index_city;

    # 以下の住所
    # $self->index_town;

    # 100分割ファイル
    $self->_100_divisions;
    return;
}

1;

__END__

検索用の json 形式ファイルの目次を作成
./tmp/index.json
index = {
    code: {
        0: './tmp/0.json',
        1: './tmp/1.json',
        ...
    },
    pref: {
        codepoint: [0, 3, 6],
    },
    city: {},
    town: {},
}

index = {
    path: {
        00: './tmp/00.json',
        01: './tmp/01.json',
        ...
        99: './tmp/99.json',
    },
    q: [
        {code: 0, pref: '', city: '', town: '', path: [00, 01, 02, ... ]}
    ],
}


