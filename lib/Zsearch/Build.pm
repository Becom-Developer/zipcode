package Zsearch::Build;
use strict;
use warnings;
use utf8;
use FindBin;
use parent 'Zsearch';
use File::Path qw(make_path remove_tree);
use Zsearch::Search;
use Data::Dumper;
use Text::CSV;

sub start {
    my ( $self, @args ) = @_;
    my $options = shift @args;
    return $self->error->commit("No arguments") if !$options;

    # 初期設定時のdbファイル準備
    return $self->_init()   if $options->{method} eq 'init';
    return $self->_insert() if $options->{method} eq 'insert';
    return $self->error->commit(
        "Method not specified correctly: $options->{method}");
}

sub _init {
    my ( $self, @args ) = @_;
    my $db_file = $self->db_file;
    my $db_dir  = File::Spec->catfile( "$FindBin::RealBin", '..', 'db' );
    my $db  = File::Spec->catfile( "$FindBin::RealBin", '..', 'db', $db_file );
    my $sql = File::Spec->catfile( "$FindBin::RealBin", '..', 'zsearch.sql' );
    die "not file: $!: $sql" if !-e $sql;
    if ( !-e $db_dir ) {
        make_path($db_dir);
    }

    # 例: sqlite3 zsearch.db < zsearch.sql
    my $cmd = "sqlite3 $db < $sql";
    system $cmd and die "Couldn'n run: $cmd ($!)";
    return +{ message => qq{build success $db_file} };
}

sub _insert {
    my ( $self, @args ) = @_;
    my $path = $self->insert_csv();
    my $dt   = $self->time_stamp;
    my $csv  = Text::CSV->new();
    my $fh   = IO::File->new( $path, "<:encoding(utf8)" );
    die "not file: $!" if !$fh;

    my $dbh  = $self->build_dbh;
    my $cols = [
        'local_code',    'zipcode_old',
        'zipcode',       'pref_kana',
        'city_kana',     'town_kana',
        'pref',          'city',
        'town',          'double_zipcode',
        'town_display',  'city_block_display',
        'double_town',   'update_zipcode',
        'update_reason', 'deleted',
        'created_ts',    'modified_ts',
    ];
    my $col = join( ',', @{$cols} );
    my $q   = [];

    for my $int ( @{$cols} ) {
        push( @{$q}, '?' );
    }
    my $values = join( ',', @{$q} );
    my $sql    = qq{INSERT INTO post ($col) VALUES ($values)};
    while ( my $row = $csv->getline($fh) ) {
        my @data = (
            $row->[0],  $row->[1],  $row->[2],  $row->[3],  $row->[4],
            $row->[5],  $row->[6],  $row->[7],  $row->[8],  $row->[9],
            $row->[10], $row->[11], $row->[12], $row->[13], $row->[14],
            0,          $dt,        $dt
        );
        my $sth = $dbh->prepare($sql);
        $sth->execute(@data) or die $dbh->errstr;
    }
    $fh->close;
    return +{ message => qq{insert success $path} };
}

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
                code => "$number",
                pref => '',
                city => '',
                town => '',
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
    my ($self) = @_;
    my @numbers = ( 0 .. 99 );
    for my $num (@numbers) {
        my $str = sprintf( "%02d", $num );

        # 保存するファイル名を決定
        my $file_path = "$FindBin::RealBin/../tmp/100/$str.json";
        my $cond      = +{
            code => $str,
            pref => '',
            city => '',
            town => '',
            path => $self->_ken_all_path,
        };
        my $rows = $self->search->csv($cond);
        $self->save_json( $file_path, $rows );
    }
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
    # $self->_100_divisions;

    # index ファイル path 一覧
    $self->_path_list;
    return;
}

sub _path_list {
    my ($self)     = @_;
    my $index_hash = $self->get_json( $self->index_path );
    my $path       = +{};
    my @numbers    = ( 0 .. 99 );
    for my $num (@numbers) {
        my $str       = sprintf( "%02d", $num );
        my $file_path = "$FindBin::RealBin/../tmp/100/$str.json";
        $path->{$str} = $file_path;
    }

    # インデックス登録
    $index_hash->{path} = $path;
    $index_hash->{q}    = [];
    $self->save_json( $self->index_path, $index_hash );
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


