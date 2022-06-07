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
    new_ok('Pickup');
    new_ok('Pickup::Error');
    new_ok('Pickup::Helper');
    new_ok('Pickup::Render');
};

subtest 'Framework Render' => sub {
    my $obj   = new_ok('Pickup::Render');
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
    my $obj   = new_ok('Pickup::Error');
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

done_testing;

__END__
