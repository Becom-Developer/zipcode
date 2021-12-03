package Zsearch::Format;
use parent 'Zsearch';
use strict;
use warnings;
use utf8;

sub zipcode {
    my ( $self, $row, $type ) = @_;
    return $row if ( $type && ( $type eq 'json' ) );
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

1;

__END__

https://www.post.japanpost.jp/zipcode/dl/readme.html

local_code -- 全国地方公共団体コード
zipcode_old -- （旧）郵便番号（5桁）
zipcode -- 郵便番号（7桁）
pref_kana -- 都道府県名
city_kana -- 市区町村名
town_kana -- 町域名
pref -- 都道府県名
city -- 市区町村名
town -- 町域名
double_zipcode -- 一町域が二以上の郵便番号で表される場合の表示 (1: 該当, 0: 該当せず)
town_display -- 小字毎に番地が起番されている町域の表示 (1: 該当, 0: 該当せず)
city_block_display -- 丁目を有する町域の場合の表示 (1: 該当, 0: 該当せず)
double_town -- 一つの郵便番号で二以上の町域を表す場合の表示 (1: 該当, 0: 該当せず)
update_zipcode -- 更新の表示 (0: 変更なし, 1: 変更あり, 2: 廃止)
update_reason -- 変更理由
    (0: 変更なし, 1: 市政・区政・町政・分区・政令指定都市施行,
     2: 住居表示の実施, 3: 区画整理, 4: 郵便区調整等, 5: 訂正, 6: 廃止)
