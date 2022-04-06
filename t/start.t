use strict;
use warnings;
use utf8;
use Test::More;
use Data::Dumper;
use FindBin;
use lib ( "$FindBin::RealBin/../lib", "$FindBin::RealBin/../local/lib/perl5" );
use Test::Trap qw/:die/;
use Zsearch;
use Zsearch::CLI;
use Zsearch::CGI;
use Encode qw(encode decode);
use JSON::PP;
use File::Temp qw/ tempfile tempdir /;
my $temp     = File::Temp->newdir( DIR => $FindBin::RealBin, CLEANUP => 1, );
my $test_dir = $temp->dirname;
$ENV{"ZSEARCH_MODE"}    = 'test';
$ENV{"ZSEARCH_TESTDIR"} = $test_dir;
$ENV{"ZSEARCH_DUMP"}    = File::Spec->catfile( $test_dir, 'zsearch.dump' );
$ENV{"ZSEARCH_DB"}      = File::Spec->catfile( $test_dir, 'zsearch.db' );

subtest 'File' => sub {
    my $script =
      File::Spec->catfile( $FindBin::RealBin, '..', 'script', 'zsearch' );
    ok( -x $script, "script file: $script" );
    my $sql = File::Spec->catfile( $FindBin::RealBin, '..', 'zsearch.sql' );
    ok( -e $sql, "sql file: $sql" );
};

subtest 'Class and Method' => sub {
    my @methods = qw{new};
    can_ok( new_ok('Zsearch'),            (@methods) );
    can_ok( new_ok('Zsearch::CLI'),       (@methods) );
    can_ok( new_ok('Zsearch::Error'),     ( qw{output commit}, @methods ) );
    can_ok( new_ok('Zsearch::Build'),     (@methods) );
    can_ok( new_ok('Zsearch::SearchSQL'), (@methods) );
    can_ok( new_ok('Zsearch::CGI'),       (@methods) );
};

subtest 'Framework Render' => sub {
    my $obj   = new_ok('Zsearch::Render');
    my $chars = '日本語';
    subtest 'raw' => sub {
        my $bytes = encode( 'UTF-8', $chars );
        trap { $obj->raw($chars) };
        like( $trap->stdout, qr/$bytes/, 'render method raw' );
    };
    subtest 'all_items_json' => sub {
        my $hash  = { jang => $chars };
        my $bytes = encode_json($hash);
        trap { $obj->all_items_json($hash) };
        like( $trap->stdout, qr/$bytes/, 'render method all_items_json' );
    };
};

subtest 'Framework Error' => sub {
    my $obj   = new_ok('Zsearch::Error');
    my $chars = '予期せぬエラー';
    subtest 'commit' => sub {
        my $hash = $obj->commit($chars);
        like( $hash->{error}->{message}, qr/$chars/, "error commit" );
    };
    subtest 'output' => sub {
        my $hash  = $obj->commit($chars);
        my $bytes = encode_json($hash);
        trap { $obj->output($chars); };
        my $commit_chars = decode( 'utf-8', $bytes );
        my $stdout_chars = decode( 'utf-8', $trap->stdout );
        chomp($stdout_chars);
        is( $commit_chars, $stdout_chars, 'error output' );
    };
};

subtest 'CLI' => sub {
    my $cli = new_ok('Zsearch::CLI');
    trap { $cli->run() };
    like( $trap->stdout, qr/error/, 'error message' );
    trap { $cli->run( '--path=build', '--method=init', ) };
    like( $trap->stdout, qr/success/, 'success message' );
};

subtest 'Build' => sub {
    my $build     = new_ok('Zsearch::Build');
    my $error_msg = $build->start();
    my @keys      = keys %{$error_msg};
    my $key       = shift @keys;
    ok( $key eq 'error', 'error message' );
    for my $method ( 'init', 'insert', 'dump' ) {
        my $output = $build->start( { method => $method } );
        like( $output->{message}, qr/success/, $output->{message} );
    }
    {
        # db ファイル削除して新しくできたもので検索テスト
        my $db = $build->db_file_path;
        unlink $db;
        ok( !-e $db, 'db file' );
        my $output = $build->start( { method => 'restore' } );
        like( $output->{message}, qr/success/, $output->{message} );
    }
};

subtest 'SearchSQL' => sub {
    my $sql       = new_ok('Zsearch::SearchSQL');
    my $error_msg = $sql->run();
    my @keys      = keys %{$error_msg};
    my $key       = shift @keys;
    ok( $key eq 'error', 'error message' );
    {
        my $test_params = +{ code => '8120041' };
        my $output      = $sql->run($test_params);
        my $message     = $output->{message};
        like( $message, qr/検索件数: 1/, encode( 'UTF-8', $message ) );
        my $zipcode = $output->{result}->[0]->{zipcode};
        ok( $zipcode eq $test_params->{code}, "code: $zipcode" );
    }
    {
        my $output = $sql->run(
            +{ code => '812', pref => '福岡', city => '福岡', town => '吉', } );
        my $message = $output->{message};
        like( $message, qr/検索件数: 2/, encode( 'UTF-8', $message ) );
    }
};

# コマンド経由で実行
# 標準入力から送られていることを想定しておく
subtest 'SearchSQL From CLI' => sub {
    my $cli = new_ok('Zsearch::CLI');
    my $test_params =
      +{ code => '812', pref => '福岡', city => '福岡', town => '吉', };

    # zsearch --code=812 --pref=福岡 --city=福岡 --town=吉
    {
        my @opt_params = ();
        while ( my ( $key, $val ) = each %{$test_params} ) {
            push @opt_params, encode( 'UTF-8', qq{--$key=$val} );
        }
        trap { $cli->run(@opt_params) };
        my $output  = decode_json( $trap->stdout );
        my $message = $output->{message};
        like( $message, qr/検索件数: 2/, encode( 'UTF-8', $message ) );
    }

    # zsearch --code= --pref=福岡 --city=福岡 --town=吉
    {
        my @opt_params = ();
        while ( my ( $key, $val ) = each %{$test_params} ) {
            if ( $key eq 'code' ) {
                push @opt_params, encode( 'UTF-8', qq{--$key=} );
            }
            else {
                push @opt_params, encode( 'UTF-8', qq{--$key=$val} );
            }
        }
        trap { $cli->run(@opt_params) };
        like( $trap->die, qr/Error/, 'die error' );
    }

    # zsearch --code=812 --pref=福岡 --city=福岡 --town=吉 --output=simple
    {
        my @opt_params = ();
        while ( my ( $key, $val ) = each %{$test_params} ) {
            push @opt_params, encode( 'UTF-8', qq{--$key=$val} );
        }
        push @opt_params, encode( 'UTF-8', '--output=simple' );
        trap { $cli->run(@opt_params) };
        my $output = decode( 'UTF-8', $trap->stdout );
        like( $output, qr/8120041 福岡県福岡市博多区吉塚/,   'simple' );
        like( $output, qr/8120046 福岡県福岡市博多区吉塚本町/, 'simple' );
        like( $output, qr/検索件数: 2/,               'simple' );
    }

    # zsearch --params='{}'
    # {"code":"812","town":"吉","pref":"福岡","city":"福岡"}
    {
        my $text_json = decode( 'UTF-8', encode_json($test_params) );
        trap { $cli->run( encode( 'UTF-8', "--params=$text_json" ) ) };
        my $output  = decode_json( $trap->stdout );
        my $message = $output->{message};
        like( $message, qr/検索件数: 2/, encode( 'UTF-8', $message ) );
    }

    # zsearch --params='{}'
    # {"code":"812","town":"吉","pref":"福岡","city":"福岡","output":"simple"}
    {
        my $text_json = decode( 'UTF-8',
            encode_json( +{ %{$test_params}, output => 'simple' } ) );
        trap { $cli->run( encode( 'UTF-8', "--params=$text_json" ) ) };
        my $output = decode( 'UTF-8', $trap->stdout );
        like( $output, qr/8120041 福岡県福岡市博多区吉塚/,   'simple' );
        like( $output, qr/8120046 福岡県福岡市博多区吉塚本町/, 'simple' );
        like( $output, qr/検索件数: 2/,               'simple' );
    }
};

done_testing;

__END__

Zsearch::CGI については手動による動作確認にしておく

local server example
python3 -m http.server 8000 --cgi

local client example
curl 'http://localhost:8000/cgi-bin/zipcode.cgi' \
--verbose \
--header 'Content-Type: application/json' \
--header 'accept: application/json' \
--data-binary '{}'

data-binary example

search
{"apikey":"becom","path":"search","method":"like","params":{}}

search params example
{"code":"812","town":"吉","pref":"福岡","city":"福岡"}

like search example
curl 'http://localhost:8000/cgi-bin/zipcode.cgi' \
--verbose \
--header 'Content-Type: application/json' \
--header 'accept: application/json' \
--data-binary '{"apikey":"becom","path":"search","method":"like","params":{"code":"812","town":"吉","pref":"福岡","city":"福岡"}}'
