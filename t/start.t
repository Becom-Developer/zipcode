use strict;
use warnings;
use utf8;
use Test::More;
use Data::Dumper;
use FindBin;
use lib ( "$FindBin::RealBin/../lib", "$FindBin::RealBin/../local/lib/perl5" );
use Test::Trap qw/:die :output(systemsafe)/;
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

subtest 'Framework Build' => sub {
    my $obj = new_ok('Zsearch::Build');
    my $msg = $obj->start()->{error}->{message};
    ok( $msg, 'error message' );
    subtest 'init' => sub {
        my $hash = $obj->start( { method => 'init' } );
        like( $hash->{message}, qr/success/, 'success init' );
        my $file_name = 'zsearch-stg.db';
        my $stg =
          $obj->start( { method => 'init', params => { name => $file_name } } );
        like( $stg->{message}, qr/$file_name/, 'success init' );
    };
    subtest 'insert' => sub {
        my $csv  = File::Spec->catfile( $FindBin::RealBin, '40FUKUOK.CSV' );
        my $hash = $obj->start(
            {
                method => 'insert',
                params => {
                    csv   => $csv,
                    table => 'post',
                    cols  => [
                        'local_code',    'zipcode_old',
                        'zipcode',       'pref_kana',
                        'city_kana',     'town_kana',
                        'pref',          'city',
                        'town',          'double_zipcode',
                        'town_display',  'city_block_display',
                        'double_town',   'update_zipcode',
                        'update_reason', 'version',
                        'deleted',       'created_ts',
                        'modified_ts',
                    ],
                    time_stamp => [ 'created_ts', 'modified_ts', ],
                    rewrite    => { version => "2022-04-28", deleted => 0 },
                }
            }
        );
        like( $hash->{message}, qr/success/, 'success insert' );
    };
    subtest 'dump' => sub {
        my $hash = $obj->start( { method => 'dump', } );
        like( $hash->{message}, qr/success/, 'success dump' );
    };
    subtest 'restore' => sub {
        my $db = $obj->db_file_path;
        unlink $db;
        ok( !-e $db, "delete db file" );
        my $hash = $obj->start( { method => 'restore', } );
        like( $hash->{message}, qr/success/, 'success restore' );
    };
};

subtest 'CLI' => sub {
    my $obj = new_ok('Zsearch::CLI');
    trap { $obj->run() };
    like( $trap->stdout, qr/error/, 'error message' );
    trap { $obj->run('foo') };
    like( $trap->stdout, qr/error/, 'error message' );
    trap { $obj->run( 'foo', 'bar' ) };
    like( $trap->stdout, qr/error/, 'error message' );
    trap { $obj->run( 'build', 'init' ) };
    like( $trap->stdout, qr/success/, 'success init' );
};

subtest 'Script' => sub {
    my $script =
      File::Spec->catfile( $FindBin::RealBin, '..', 'script', 'zsearch' );
    trap { system $script };
    my $foo = $trap->stdout;
    like( $trap->stdout, qr/error/, 'error message' );
    trap { system "$script build init" };
    like( $trap->stdout, qr/success/, 'success init' );
};

subtest 'SearchSQL' => sub {
    new_ok('Zsearch::Build')->start( { method => 'init' } );
    my $csv          = File::Spec->catfile( $FindBin::RealBin, '40FUKUOK.CSV' );
    my $test_version = '2022-04-28';
    new_ok('Zsearch::Build')->start(
        {
            method => 'insert',
            params => {
                csv   => $csv,
                table => 'post',
                cols  => [
                    'local_code',    'zipcode_old',
                    'zipcode',       'pref_kana',
                    'city_kana',     'town_kana',
                    'pref',          'city',
                    'town',          'double_zipcode',
                    'town_display',  'city_block_display',
                    'double_town',   'update_zipcode',
                    'update_reason', 'version',
                    'deleted',       'created_ts',
                    'modified_ts',
                ],
                time_stamp => [ 'created_ts', 'modified_ts', ],
                rewrite    => { version => $test_version, deleted => 0 },
            }
        }
    );
    my $obj = new_ok('Zsearch::SearchSQL');
    my $msg = $obj->run()->{error}->{message};
    ok( $msg, 'error message' );
    {
        my $test_params = +{ code => '8120041' };
        my $args        = { method => "like", params => $test_params };
        my $output      = $obj->run($args);
        warn $obj->dump($output);
        my $message = $output->{message};
        like( $message, qr/検索件数: 1/, encode( 'UTF-8', $message ) );
        my $zipcode = $output->{data}->[0]->{zipcode};
        ok( $zipcode eq $test_params->{code}, "code: $zipcode" );
        my $version = $output->{version};
        is( $version, $test_version, "version" );
        my $count = $output->{count};
        is( $count, 1, "count" );
    }
    {
        my $test_params =
          +{ code => '812', pref => '福岡', city => '福岡', town => '吉', };
        my $args    = { method => "like", params => $test_params };
        my $output  = $obj->run($args);
        my $message = $output->{message};
        like( $message, qr/検索件数: 2/, encode( 'UTF-8', $message ) );
    }

    # 検索結果がないとき
    {
        my $test_params =
          +{ code => '912', pref => '岡', city => '福', town => '吉', };
        my $args    = { method => "like", params => $test_params };
        my $output  = $obj->run($args);
        my $message = $output->{message};
        like( $message, qr/検索件数: 0/, encode( 'UTF-8', $message ) );
        is( @{ $output->{data} }, 0, 'data' );
    }
};

# コマンド経由で実行
# 標準入力から送られていることを想定しておく
subtest 'SearchSQL From CLI' => sub {
    my $cli = new_ok('Zsearch::CLI');
    my $test_params =
      +{ code => '812', pref => '福岡', city => '福岡', town => '吉', };

    # zsearch search like --params='{}'
    # {"code":"812","pref":"福岡","city":"福岡","town":"吉"}
    {
        my @opt_params = ();
        push @opt_params, encode( 'UTF-8', qq{search} );
        push @opt_params, encode( 'UTF-8', qq{like} );
        my $bytes  = encode_json($test_params);
        my $params = encode( 'UTF-8', qq{--params=} );
        my $opt    = $params . $bytes;
        push @opt_params, $opt;
        trap { $cli->run(@opt_params) };
        my $output  = decode_json( $trap->stdout );
        my $message = $output->{message};
        like( $message, qr/検索件数: 2/, encode( 'UTF-8', $message ) );
    }

    # zsearch search like --params='{}'
    # {"code":"","pref":"福岡","city":"福岡","town":"吉"}
    {
        my @opt_params = ();
        push @opt_params, encode( 'UTF-8', qq{search} );
        push @opt_params, encode( 'UTF-8', qq{like} );
        my $none_code = { %{$test_params} };
        $none_code->{code} = "";
        my $bytes  = encode_json($none_code);
        my $params = encode( 'UTF-8', qq{--params=} );
        my $opt    = $params . $bytes;
        push @opt_params, $opt;
        trap { $cli->run(@opt_params) };
        my $output  = decode_json( $trap->stdout );
        my $message = $output->{message};
        like( $message, qr/検索件数: 3/, encode( 'UTF-8', $message ) );
    }

    # zsearch search like --params='{}'
    # {"code":"812","pref":"福岡","city":"福岡","town":"吉","output":"simple"}
    {
        my @opt_params = ();
        push @opt_params, encode( 'UTF-8', qq{search} );
        push @opt_params, encode( 'UTF-8', qq{like} );
        my $output_simple = { %{$test_params} };
        $output_simple->{output} = "simple";
        my $bytes  = encode_json($output_simple);
        my $params = encode( 'UTF-8', qq{--params=} );
        my $opt    = $params . $bytes;
        push @opt_params, $opt;
        trap { $cli->run(@opt_params) };
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
{"zipcode":"812","town":"吉","pref":"福岡","city":"福岡"}

like search example
curl 'http://localhost:8000/cgi-bin/zipcode.cgi' \
--verbose \
--header 'Content-Type: application/json' \
--header 'accept: application/json' \
--data-binary '{"apikey":"becom","path":"search","method":"like","params":{"zipcode":"812","town":"吉","pref":"福岡","city":"福岡"}}'
