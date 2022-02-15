use strict;
use warnings;
use utf8;
use Test::More;
use Data::Dumper;
use FindBin;
use lib ( "$FindBin::RealBin/../lib", "$FindBin::RealBin/../local/lib/perl5" );
use Test::Trap qw/:die/;
use Zsearch;
use Zsearch::Command;
use Zsearch::CGI;
use Encode qw(encode decode);
use JSON::PP;
$ENV{"ZSEARCH_MODE"} = 'test';

subtest 'Class and Method' => sub {
    my @methods = qw{new};
    can_ok( new_ok('Zsearch'),            (@methods) );
    can_ok( new_ok('Zsearch::Command'),   (@methods) );
    can_ok( new_ok('Zsearch::Error'),     ( qw{output commit}, @methods ) );
    can_ok( new_ok('Zsearch::Build'),     (@methods) );
    can_ok( new_ok('Zsearch::SearchSQL'), (@methods) );
    can_ok( new_ok('Zsearch::CGI'),       (@methods) );
};

subtest 'Command' => sub {
    my $cli = new_ok('Zsearch::Command');
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
    my $msg       = $build->start( { method => 'init' } );
    my $build_msg = 'build success zsearch-test.db';
    ok( $msg->{message} eq $build_msg, $build_msg );
    my $insert_msg = $build->start( { method => 'insert' } );
    like( $insert_msg->{message}, qr/success/, $insert_msg->{message} );
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
subtest 'SearchSQL From Command' => sub {
    my $cli = new_ok('Zsearch::Command');
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

build はタイムアウトするかもしれない
{"apikey":"becom","path":"build","method":"init"}
{"apikey":"becom","path":"build","method":"insert"}

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

curl 'http://localhost:8000/cgi-bin/zipcode.cgi' \
--verbose \
--header 'Content-Type: application/json' \
--header 'accept: application/json' \
--data-binary '{"apikey":"becom","path":"build","method":"init"}'

curl 'http://localhost:8000/cgi-bin/zipcode.cgi' \
--verbose \
--header 'Content-Type: application/json' \
--header 'accept: application/json' \
--data-binary '{"apikey":"becom","path":"build","method":"insert"}'
