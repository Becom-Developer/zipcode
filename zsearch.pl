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
my $code = '8120041';
my $path = './csv/40FUKUOK.CSV';
my $json;
GetOptions(
    "code=i" => \$code,
    "path=s" => \$path,
    "json"   => \$json
) or die("Error in command line arguments\n");

# 検索条件

# 検索実行
my $csv = Text::CSV->new();
open my $fh, "<:encoding(utf8)", $path or die "test.csv: $!";
my @rows;
while ( my $row = $csv->getline($fh) ) {
    if ( $row->[2] =~ /^$code/ ) {
        push @rows,
          +{
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
}

# 実行結果の整形
my $output;
for my $row (@rows) {
    $output .= "$row->{zipcode} $row->{pref}$row->{city}$row->{town}\n";
}

# 出力
my $byte_address = encode( 'UTF-8', $output );
print $byte_address. "\n";
close $fh;

# warn $code;

# for my $byte_text (@ARGV) {
#     my $text     = decode( 'UTF-8', $byte_text );
#     my $count    = length $text;
#     my $msg      = "入力した文字: $text, 文字数: $count\n";
#     my $byte_msg = encode( 'UTF-8', $msg );
#     print $byte_msg;
# }

# my @rows;
# my $address;

# # Read/parse CSV
# my $csv = Text::CSV->new();
# open my $fh, "<:encoding(utf8)", $path or die "test.csv: $!";
# while ( my $row = $csv->getline($fh) ) {
#     my $zipcode = $row->[2];

#     if ( $zipcode eq $code ) {

#         # if ( $row->[13] eq 0 ) {
#         push @rows,
#           +{
#             local_code         => $row->[0],
#             zipcode_old        => $row->[1],
#             zipcode            => $row->[2],
#             pref_kana          => $row->[3],
#             city_kana          => $row->[4],
#             town_kana          => $row->[5],
#             pref               => $row->[6],
#             city               => $row->[7],
#             town               => $row->[8],
#             double_zipcode     => $row->[10],
#             town_display       => $row->[11],
#             city_block_display => $row->[12],
#             double_town        => $row->[13],
#             update_zipcode     => $row->[14],
#             update_reason      => $row->[15],
#           };
#     }
# }

# # warn Dumper \@rows;

# my $utf8_encoded_json_text = encode_json \@rows;
# warn Dumper $utf8_encoded_json_text;

# # my $line = '';
# # for my $row (@rows) {

# #     $line .=
# #         $row->[0]
# #       . $row->[1]
# #       . $row->[2]
# #       . $row->[3]
# #       . $row->[4]
# #       . $row->[5]
# #       . $row->[6]
# #       . $row->[7]
# #       . $row->[8]
# #       . $row->[10]
# #       . $row->[11]
# #       . $row->[12]
# #       . $row->[13]
# #       . $row->[14]
# #       . $row->[15];

# # }

# # my $byte_address = encode( 'UTF-8', $line );

# # print $byte_address. "\n";
# close $fh;

# local_code -- 全国地方公共団体コード（JIS X0401、X0402）………　半角数字
# zipcode_old -- （旧）郵便番号（5桁）………………………………………　半角数字
# zipcode -- 郵便番号（7桁）………………………………………　半角数字
# pref_kana -- 都道府県名　…………　半角カタカナ（コード順に掲載）　（注1）
# city_kana -- 市区町村名　…………　半角カタカナ（コード順に掲載）　（注1）
# town_kana -- 町域名　………………　半角カタカナ（五十音順に掲載）　（注1）
# pref -- 都道府県名　…………　漢字（コード順に掲載）　（注1,2）
# city -- 市区町村名　…………　漢字（コード順に掲載）　（注1,2）
# town -- 町域名　………………　漢字（五十音順に掲載）　（注1,2）
# double_zipcode -- 一町域が二以上の郵便番号で表される場合の表示　（注3）　（「1」は該当、「0」は該当せず）
# town_display -- 小字毎に番地が起番されている町域の表示　（注4）　（「1」は該当、「0」は該当せず）
# city_block_display -- 丁目を有する町域の場合の表示　（「1」は該当、「0」は該当せず）
# double_town -- 一つの郵便番号で二以上の町域を表す場合の表示　（注5）　（「1」は該当、「0」は該当せず）
# update_zipcode -- 更新の表示（注6）（「0」は変更なし、「1」は変更あり、「2」廃止（廃止データのみ使用））
# update_reason -- 変更理由　（「0」は変更なし、「1」市政・区政・町政・分区・政令指定都市施行、「2」住居表示の実施、「3」区画整理、「4」郵便区調整等、「5」訂正、「6」廃止（廃止データのみ
