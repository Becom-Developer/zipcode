use strict;
use warnings;
use utf8;
use Test::More;
use Data::Dumper;
use FindBin;
use lib ( "$FindBin::RealBin/../lib", "$FindBin::RealBin/../local/lib/perl5" );
use Test::Trap;
use Zsearch;
use Zsearch::CLI2;
$ENV{"ZSEARCH_MODE"} = 'test';

subtest 'Class and Method' => sub {
    my @methods = qw{new};
    can_ok( new_ok('Zsearch'), (@methods) );
    can_ok( new_ok('Zsearch::CLI2'), (@methods) );
    can_ok( new_ok('Zsearch::Error'), ( qw{output commit}, @methods ) );
    can_ok( new_ok('Zsearch::Build'), (@methods) );
};

subtest 'CLI2' => sub {
    my $cli = new_ok('Zsearch::CLI2');
    trap { $cli->run() };
    like( $trap->stdout, qr/error/, $trap->stdout );
    trap { $cli->run( '--path=build', '--method=init', ) };
    like( $trap->stdout, qr/success/, $trap->stdout );
};

subtest 'Build' => sub {
    my $build = new_ok('Zsearch::Build');
    my $error_msg = $build->run2();
    my @keys      = keys %{$error_msg};
    my $key       = shift @keys;
    ok( $key eq 'error', 'error message' );
    my $msg       = $build->run2( { method => 'init' } );
    my $build_msg = 'build success zsearch-test.db';
    ok( $msg->{message} eq $build_msg, $build_msg );
    my $insert_msg = $build->run2( { method => 'insert' } );
    warn $insert_msg->{message};
};

done_testing;
