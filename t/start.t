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
    can_ok( new_ok('Zsearch::Error'), ( qw{output  commit}, @methods ) );
    can_ok( new_ok('Zsearch::Build'), (@methods) );
};

subtest 'CLI2' => sub {
    my $cli = new_ok('Zsearch::CLI2');
    trap { $cli->run() };
    like( $trap->stdout, qr/error/, $trap->stdout );
    trap { $cli->run( '--path=build', '--method=init' ) };
    like( $trap->stdout, qr/success/, $trap->stdout );
};

done_testing;
