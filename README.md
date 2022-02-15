# zipcode

郵便番号から住所を検索するコマンドラインアプリ

## SETUP

ホームディレクトリ配下 bin ディレクトリを起動ファイルの置き場にしている場合

シンボリックリンクを作成 (パスは読み替えてください)

```zsh
cd ~/bin
ln -s ~/github/zipcode/script/zsearch zsearch
```

input

```zsh
zsearch --code=812
zsearch --code=812 --output=simple
zsearch --code=812 --pref=福岡 --city=福岡 --town=吉 --output=json
zsearch --path=build --method=init
zsearch --params='{}'
```

```json
{
  "code": 812,
  "pref": "福岡",
  "city": "福岡",
  "town": "吉",
  "output": "json"
}
```

```zsh
curl 'https://zsearch-api.becom.co.jp/zsearch.cgi' \
--verbose \
--request POST \
--header 'Content-Type: application/json' \
--header 'accept: application/json' \
--data-binary '{"apikey":"becom","params":{}}'
```

output

```text
8120862 福岡県福岡市博多区立花寺
8120039 福岡県福岡市博多区冷泉町
検索件数: 90
```

```json
{
  "message": "検索件数: 90",
  "result": [
    {
      "code": 8120862,
      "pref": "福岡県",
      "city": "福岡市博多区",
      "town": "立花寺"
    },
    {
      "code": 8120039,
      "pref": "福岡県",
      "city": "福岡市博多区",
      "town": "冷泉町"
    }
  ]
}
```

```text
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
```
