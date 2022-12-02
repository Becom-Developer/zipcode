use strict;
use warnings;
use utf8;
use Test::More;
use Data::Dumper;
use FindBin;
use lib ( "$FindBin::RealBin/../lib", "$FindBin::RealBin/../local/lib/perl5" );
use Test::Trap qw/:die :output(systemsafe)/;
use Zsearch;
use Pickup;
use Grecaptcha;
use Encode qw(encode decode);
use JSON::PP;
use File::Temp qw/ tempfile tempdir /;
my $temp     = File::Temp->newdir( DIR => $FindBin::RealBin, CLEANUP => 1, );
my $test_dir = $temp->dirname;
$ENV{"ZSEARCH_MODE"}    = 'test';
$ENV{"ZSEARCH_TESTDIR"} = $test_dir;
$ENV{"ZSEARCH_DUMP"}    = File::Spec->catfile( $test_dir, 'zsearch.dump' );
$ENV{"ZSEARCH_DB"}      = File::Spec->catfile( $test_dir, 'zsearch.db' );

subtest 'Class and Method' => sub {
    my @methods = qw{new};
    can_ok( new_ok('Grecaptcha'), (@methods) );
};

subtest 'Grecaptcha' => sub {
    my $obj = new_ok('Grecaptcha');
    my $msg = $obj->run()->{error}->{message};
    ok( $msg, 'error message' );

    # 本来は html マークアップ画面での token 取得が必要だが省略
    # 無効な token リクエストの失敗判定のみにしておく
    my $params = +{ response => '03AEkXODDH6jrUfANvX5rMvt6LkkEI8yonAIk-H56_' };
    my $args   = { method => "siteverify", params => $params };
    my $output = $obj->run($args);
    my $error_codes = $output->{content}->{'error-codes'};
    my $error_code  = shift @{$error_codes};
    like( $error_code, qr/invalid-input-response/, 'error_code' );
};

# コマンド経由で実行
# 標準入力から送られていることを想定しておく
subtest 'Grecaptcha From CLI' => sub {
    my $cli = new_ok('Zsearch::CLI');
    my $test_params =
      +{ response => '03AEkXODDH6jrUfANvX5rMvt6LkkEI8yonAIk-H56_' };
    my @opt_params = ();
    push @opt_params, encode( 'UTF-8', qq{grecaptcha} );
    push @opt_params, encode( 'UTF-8', qq{siteverify} );
    my $bytes  = encode_json($test_params);
    my $params = encode( 'UTF-8', qq{--params=} );
    my $opt    = $params . $bytes;
    trap { $cli->run(@opt_params) };
    my $output      = decode_json( $trap->stdout );
    my $error_codes = $output->{content}->{'error-codes'};
    my $error_code  = shift @{$error_codes};
    like( $error_code, qr/invalid-input-response/, 'error_code' );
};

done_testing;

__END__
