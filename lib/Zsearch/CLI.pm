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
my $path = Zsearch::csv_all_path();
my $type = 'standard';
my $mode = 'auto';
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
    return $self->build->run if $mode eq 'build';

    # csv データから条件検索して結果を取得
    my $cond = +{
        code => $code,
        pref => $pref,
        city => $city,
        town => $town,
        path => $path,
        mode => $mode,
    };
    my $rows = $self->search->json($cond);

    # 結果を画面表示 (標準出力へ標準の形式での)
    $self->render->stdout( $type, $rows );
    return;
}

1;

__END__

郵便番号および住所の前方一致絞り込み検索アプリ

検索用インデックスの作成
zsearch --mode=build

郵便番号検索
zsearch --mode=auto --code=812

省略した指定
zsearch --code=812

json 形式で出力
zsearch --type=json --code=812

項目による絞り込み検索
zsearch --code=812 --pref=福岡 --city=福岡 --town=吉

csv ファイルによる絞り込み検索
zsearch --mode=csv --code=812 --pref=福岡 --city=福岡 --town=吉

csv ファイルによる絞り込み検索
zsearch --mode=csv --code=812 --pref=福岡 --city=福岡 --town=吉
