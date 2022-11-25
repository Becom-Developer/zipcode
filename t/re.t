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

subtest 'File' => sub {
    my $script =
      File::Spec->catfile( $FindBin::RealBin, '..', 'script', 'zsearch' );
    ok( -x $script, "script file: $script" );
    my $sql = File::Spec->catfile( $FindBin::RealBin, '..', 'zsearch.sql' );
    ok( -e $sql, "sql file: $sql" );
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
        my $csv  = File::Spec->catfile( $FindBin::RealBin, '40FUKUOKMINI.CSV' );
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
};

subtest 'SearchSQL' => sub {
    my $obj = new_ok('Zsearch::SearchSQL');

    {
        my $test_params =
          +{ zipcode => '812', pref => '福岡', city => '福岡', town => '吉', };

        $test_params->{grecaptcha} = +{
            action   => "submit",
            response => "6LcivDEjAAAAAOxO0_k4VwMJ4_",
        };

        my $args    = { method => "like", params => $test_params };
        my $output  = $obj->run($args);
        my $message = $output->{message};
        like( $message, qr/検索件数: 2/, encode( 'UTF-8', $message ) );
    }
};

done_testing;

__END__
