DROP TABLE IF EXISTS post;

-- 郵便番号情報
CREATE TABLE post (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    -- ID (例: 5)
    local_code TEXT -- 全国地方公共団体コード
    zipcode_old TEXT -- （旧）郵便番号（5桁）
    zipcode TEXT -- 郵便番号（7桁）
    pref_kana TEXT -- 都道府県名
    city_kana TEXT -- 市区町村名
    town_kana TEXT -- 町域名
    pref TEXT -- 都道府県名
    city TEXT -- 市区町村名
    town TEXT -- 町域名
    double_zipcode TEXT -- 一町域が二以上の郵便番号で表される場合の表示 (1: 該当, 0: 該当せず)
    town_display TEXT -- 小字毎に番地が起番されている町域の表示 (1: 該当, 0: 該当せず)
    city_block_display TEXT -- 丁目を有する町域の場合の表示 (1: 該当, 0: 該当せず)
    double_town TEXT -- 一つの郵便番号で二以上の町域を表す場合の表示 (1: 該当, 0: 該当せず)
    update_zipcode TEXT -- 更新の表示 (0: 変更なし, 1: 変更あり, 2: 廃止)
    update_reason TEXT -- 変更理由 (0: 変更なし, 1: 市政・区政・町政・分区・政令指定都市施行, 2: 住居表示の実施, 3: 区画整理, 4: 郵便区調整等, 5: 訂正, 6: 廃止)
    deleted INTEGER,
    -- 削除フラグ (例: 0: 削除していない, 1: 削除済み)
    created_ts TEXT,
    -- 登録日時 (例: '2022-01-23 23:49:12')
    modified_ts TEXT -- 修正日時 (例: '2022-01-23 23:49:12')
);