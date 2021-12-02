package Zsearch::CLI;
use parent 'Zsearch';
use Zsearch::Render;
use Zsearch::Search;
use Zsearch::Build;
use strict;
use warnings;
use utf8;
use Encode qw(encode decode);
use Data::Dumper;
use Getopt::Long;

sub hello  { print "hello CLI-----\n"; }
sub search { return Zsearch::Search->new; }
sub render { return Zsearch::Render->new; }
sub build  { return Zsearch::Build->new; }

# オプションの設定
my ( $code, $pref, $city, $town ) = '';
my $path = './csv/40FUKUOK.CSV';
my $type = 'standard';
my $mode = 'search';
GetOptions(
    "code=i" => \$code,
    "pref=s" => \$pref,
    "city=s" => \$city,
    "town=s" => \$town,
    "path=s" => \$path,
    "type=s" => \$type,
    "mode=s" => \$mode,
) or die("Error in command line arguments\n");

$code = decode( 'UTF-8', $code );
$pref = decode( 'UTF-8', $pref );
$city = decode( 'UTF-8', $city );
$town = decode( 'UTF-8', $town );
$type = decode( 'UTF-8', $type );
$mode = decode( 'UTF-8', $mode );

sub run {
    my ( $self, @args ) = @_;

    # 検索用インデックスの作成
    if ( $mode eq 'build' ) {
        $self->build->run;
        return;
    }

    # csv データから条件検索して結果を取得
    my $cond = +{
        code => $code,
        pref => $pref,
        city => $city,
        town => $town,
        path => $path,
    };
    my $rows = $self->search->json($cond);

    # 結果を画面表示 (標準出力へ標準の形式での)
    $self->render->stdout( $type, $rows );
    return;
}

1;
