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
};

subtest 'Command' => sub {
    my $cli = new_ok('Zsearch::Command');
    trap { $cli->run() };
    like( $trap->stdout, qr/error/, $trap->stdout );
    trap { $cli->run( '--path=build', '--method=init', ) };
    like( $trap->stdout, qr/success/, $trap->stdout );
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
    ok( $key eq 'error', $error_msg->{$key} );
    my $test_code = '8120041';
    my $msg       = $sql->run( { code => $test_code } );
    my $message   = $msg->{message};
    like( $message, qr/検索件数: 1/, encode( 'UTF-8', $message ) );
    my $result = $msg->{result}->[0];
    ok( $result->{zipcode} eq $test_code, "code: $result->{zipcode}" );
    my $test_opt = +{ code => '812', pref => '福岡', city => '福岡', town => '吉', };
    $msg     = $sql->run($test_opt);
    $message = $msg->{message};
    like( $message, qr/検索件数: 2/, encode( 'UTF-8', $message ) );

    # コマンド経由で実行
    my $cli = new_ok('Zsearch::Command');

    # 標準入力から送られていることを想定しておく
    my @opt_params = (
        encode( 'UTF-8', '--code=812' ),
        encode( 'UTF-8', '--pref=福岡' ),
        encode( 'UTF-8', '--city=福岡' ),
        encode( 'UTF-8', '--town=吉' ),
    );
    trap { $cli->run(@opt_params) };
    my $stdout = decode_json( $trap->stdout );
    like( $stdout->{message}, qr/検索件数: 2/,
        encode( 'UTF-8', $stdout->{message} ) );
    trap {
        $cli->run(
            encode( 'UTF-8', '--code=' ),
            encode( 'UTF-8', '--pref=福岡' ),
            encode( 'UTF-8', '--city=福岡' ),
            encode( 'UTF-8', '--town=吉' ),
        )
    };
    like( $trap->die, qr/Error/, encode( 'UTF-8', $trap->die ) );

    # 出力をシンプルモードに
    my @opt_params_simple =
      ( @opt_params, encode( 'UTF-8', '--output=simple' ) );
    trap {
        $cli->run(@opt_params_simple);
    };
    $stdout = decode( 'UTF-8', $trap->stdout );
    like( $stdout, qr/8120041 福岡県福岡市博多区吉塚/,   'simple' );
    like( $stdout, qr/8120046 福岡県福岡市博多区吉塚本町/, 'simple' );
    like( $stdout, qr/検索件数: 2/,               'simple' );

};

done_testing;
