#!/usr/bin/env perl
use strict;
use warnings;
use utf8;
use Encode qw(encode decode);
use Text::CSV;
use Data::Dumper;
use JSON::PP;
use Getopt::Long;

# オプションの設定
my ( $code, $pref, $city, $town ) = '';
my $path = './csv/40FUKUOK.CSV';
my $type = 'text';
GetOptions(
    "code=i" => \$code,
    "pref=s" => \$pref,
    "city=s" => \$city,
    "town=s" => \$town,
    "path=s" => \$path,
    "type=s" => \$type,
) or die("Error in command line arguments\n");

# 検索条件
$code = decode( 'UTF-8', $code );
$pref = decode( 'UTF-8', $pref );
$city = decode( 'UTF-8', $city );
$town = decode( 'UTF-8', $town );

sub _search_cond {
    my ( $code, $pref, $city, $town, $row ) = @_;
    my $r_code = $row->[2];
    my $r_pref = $row->[6];
    my $r_city = $row->[7];
    my $r_town = $row->[8];
    if ( $code && $pref && $city && $town ) {
        return if $r_code !~ /^$code/;
        return if $r_pref !~ /^$pref/;
        return if $r_city !~ /^$city/;
        return if $r_town !~ /^$town/;
        return _zip_paramas($row);
    }
    if ( $code && $pref && $city ) {
        return if $r_code !~ /^$code/;
        return if $r_pref !~ /^$pref/;
        return if $r_city !~ /^$city/;
        return _zip_paramas($row);
    }
    if ( $code && $pref && $town ) {
        return if $r_code =~ /^$code/;
        return if $r_pref =~ /^$pref/;
        return if $r_town =~ /^$town/;
        return _zip_paramas($row);
    }
    if ( $code && $city && $town ) {
        return if $r_code !~ /^$code/;
        return if $r_city !~ /^$city/;
        return if $r_town !~ /^$town/;
        return _zip_paramas($row);
    }
    if ( $pref && $city && $town ) {
        return if $r_pref !~ /^$pref/;
        return if $r_city !~ /^$city/;
        return if $r_town !~ /^$town/;
        return _zip_paramas($row);
    }
    if ( $city && $town ) {
        return if $r_city !~ /^$city/;
        return if $r_town !~ /^$town/;
        return _zip_paramas($row);
    }
    if ( $pref && $town ) {
        return if $r_pref !~ /^$pref/;
        return if $r_town !~ /^$town/;
        return _zip_paramas($row);
    }
    if ( $pref && $city ) {
        return if $r_pref !~ /^$pref/;
        return if $r_city !~ /^$city/;
        return _zip_paramas($row);
    }
    if ( $code && $town ) {
        return if $r_code !~ /^$code/;
        return if $r_town !~ /^$town/;
        return _zip_paramas($row);
    }
    if ( $code && $city ) {
        return if $r_code !~ /^$code/;
        return if $r_city !~ /^$city/;
        return _zip_paramas($row);
    }
    if ( $code && $pref ) {
        return if $r_code !~ /^$code/;
        return if $r_pref !~ /^$pref/;
        return _zip_paramas($row);
    }
    return _zip_paramas($row) if $code && ( $r_code =~ /^$code/ );
    return _zip_paramas($row) if $pref && ( $r_pref =~ /^$pref/ );
    return _zip_paramas($row) if $city && ( $r_city =~ /^$city/ );
    return _zip_paramas($row) if $town && ( $r_town =~ /^$town/ );
    return;
}

# 検索実行
my $csv = Text::CSV->new();
open my $fh, "<:encoding(utf8)", $path or die "test.csv: $!";
my @rows;
while ( my $row = $csv->getline($fh) ) {
    if ( my $params = _search_cond( $code, $pref, $city, $town, $row ) ) {
        push @rows, $params;
    }
}
close $fh;

warn ord $pref;
# my $path_json = './tmp/1.json';
# my $fh_json = IO::File->new("> $path_json");
# if (defined $fh_json) {
#     print $fh_json encode_json \@rows;
#     $fh_json->close;
# }

# open my $fh_json, $path_json or die "test.csv: $!";

# my $json = encode_json \@rows;
# print $fh_json $json . "\n";

# for my $row (@rows) {
#      my $json = encode_json \@rows;
#     print $fh_json $json."\n";
#     # print encode( 'UTF-8', $row->{zipcode} );
#     # print "\n";
# }

# データ整形
sub _zip_paramas {
    my $row = shift;
    return +{
        local_code         => $row->[0],
        zipcode_old        => $row->[1],
        zipcode            => $row->[2],
        pref_kana          => $row->[3],
        city_kana          => $row->[4],
        town_kana          => $row->[5],
        pref               => $row->[6],
        city               => $row->[7],
        town               => $row->[8],
        double_zipcode     => $row->[10],
        town_display       => $row->[11],
        city_block_display => $row->[12],
        double_town        => $row->[13],
        update_zipcode     => $row->[14],
        update_reason      => $row->[15],
    };
}

# 実行結果の整形

# 出力
my $byte_address;
if ( $type eq 'text' ) {
    my $output;
    for my $row (@rows) {
        $output .= "$row->{zipcode} $row->{pref}$row->{city}$row->{town}\n";
    }
    my $count = @rows;
    $byte_address = encode( 'UTF-8', $output );
    $byte_address .= encode( 'UTF-8', "検索件数: $count" );
}

if ( $type eq 'json' ) {
    my $output = [];
    for my $row (@rows) {
        push @{$output},
          +{
            zipcode => $row->{zipcode},
            pref    => $row->{pref},
            city    => $row->{city},
            town    => $row->{town},
          };
    }
    $byte_address = encode_json $output;
}

# print $byte_address. "\n";

# 条件まとめ
# code, pref, city, town
# code, pref, city
# code, pref,       town
# code,       city, town
#       pref, city, town
#             city, town
#       pref,       town
#       pref, city
# code,             town
# code,       city
# code, pref
# code,
#       pref
#             city
#                   town
# # code 必須
# code, pref, city, town
# code, pref, city
# code, pref,       town
# code,       city, town
# code, pref
# code,       city
# code,             town
# code,
# # pref 必須
# code, pref, city, town
#       pref, city, town
# code, pref,       town
# code, pref, city,
#       pref,       town
# code, pref
#       pref, city
#       pref
# # city 必須
# code, pref, city, town
#       pref, city, town
# code,       city, town
# code, pref, city
#             city, town
# code,       city
#       pref, city
#             city
# # town 必須
# code, pref, city, town
#       pref, city, town
# code,       city, town
# code, pref,       town
#             city, town
# code,             town
#       pref,       town
#                   town

# local_code -- 全国地方公共団体コード（JIS X0401、X0402）………　半角数字
# zipcode_old -- （旧）郵便番号（5桁）………………………………………　半角数字
# zipcode -- 郵便番号（7桁）………………………………………　半角数字
# pref_kana -- 都道府県名　…………　半角カタカナ（コード順に掲載）　（注1）
# city_kana -- 市区町村名　…………　半角カタカナ（コード順に掲載）　（注1）
# town_kana -- 町域名　………………　半角カタカナ（五十音順に掲載）　（注1）
# pref -- 都道府県名　…………　漢字（コード順に掲載）　（注1,2）
# city -- 市区町村名　…………　漢字（コード順に掲載）　（注1,2）
# town -- 町域名　………………　漢字（五十音順に掲載）　（注1,2）
# double_zipcode -- 一町域が二以上の郵便番号で表される場合の表示　（注3）　（「1���は該当、「0」は該当せず）
# town_display -- 小字毎に番地が起番されている町域の表示　（注4）　（「1」は該当、「0」は該当せず）
# city_block_display -- 丁目を有する町域の場合の表示　（「1」は該当、「0」は該当せず）
# double_town -- 一つの郵便番号で二以上の町域を表す場合の表示　（注5）　（「1」は該当、「0」は該当せず）
# update_zipcode -- 更新の表示（注6）（「0」は変更なし、「1」は変更あり、「2」廃止（廃止データのみ使用））
# update_reason -- 変更理由　（「0」は変更���し、「1」市政・区政・町政・分区・政令指定都市施行、「2」住居表示の実施、「3」区画整理、「4」郵便区調整等、「5」訂正、「6」廃止（廃止データのみ

__END__
--index=auto が指定されている場合

検索用の index ファイル一式を作成
lib/Buildindex.pm

script/



検索用の json 形式ファイルの目次を作成
./tmp/index.json
index = {
    code: {
        0: './tmp/0.json',
        1: './tmp/1.json',
        ...
    },
    pref: {
        codepoint: './tmp/codepoint.json',
    },
    city: {},
    town: {},
}

zipcode 別のインデックスを作成
