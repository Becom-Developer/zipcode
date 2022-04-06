# zsearch-api

郵便番号から住所を検索するコマンドラインアプリ

## SETUP

ホームディレクトリ配下 bin ディレクトリを起動ファイルの置き場にしている場合

シンボリックリンクを作成 (パスは読み替えてください)

```zsh
cd ~/bin
ln -s ~/github/zsearch-api/script/zsearch zsearch
```

Module

```zsh
curl -L https://cpanmin.us/ -o cpanm
chmod +x cpanm
./cpanm -l ./local --installdeps .
```

デプロイ

```zsh
ssh becom2022@becom2022.sakura.ne.jp
cd ~/www/zsearch-api
git fetch && git checkout main && git pull
```

ローカル環境での実行

```sh
perl -I ./local/lib/perl5 ./local/bin/morbo ./script/app
```

input

```zsh
zsearch --code=812
zsearch --code=812 --output=simple
zsearch --code=812 --pref=福岡 --city=福岡 --town=吉 --output=json
zsearch --path=build --method=init
zsearch --path=build --method=insert
zsearch --path=build --method=dump
zsearch --path=build --method=restore
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

`like search example`

```zsh
curl 'https://zsearch-api.becom.co.jp/' \
--verbose \
--header 'Content-Type: application/json' \
--header 'accept: application/json' \
--data-binary '{"apikey":"becom","path":"search","method":"like","params":{"code":"812","town":"吉","pref":"福岡","city":"福岡"}}'
```

```zsh
curl 'https://zsearch-api.becom.co.jp/' \
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

## Data

郵便番号の元データについて

郵便局のwebサイトから郵便番号データダウンロードをおこなう

- 郵便番号データダウンロード
  - <https://www.post.japanpost.jp/zipcode/download.html>
- 読み仮名データの促音・拗音を小書きで表記するもの(zip形式)
  - <https://www.post.japanpost.jp/zipcode/dl/kogaki-zip.html>
- ダウンロードデータについての注意
  - <https://www.post.japanpost.jp/zipcode/dl/readme.html>

コマンドを使ったダウンロードの例

```zsh
curl -O https://www.post.japanpost.jp/zipcode/dl/jigyosyo/zip/jigyosyo.zip
```

文字コードの問題

```text
※1 文字コードには、MS漢字コード（SHIFT JIS）を使用しています。
※2 文字セットとして、JIS X0208-1983を使用し、規定されていない文字はひらがなで表記しています。
1レコードの区切りは、キャリッジリターン（CR）＋ラインフィード（LF）です。
```

- 文字コードはutf8に整え、改行コードはLF
  - nkf を活用して処理
  - nkf は入力側のテキストの文字コードは自動判定してくれる

homebrew を使った入手

```zsh
brew install nkf
```

ダウンロードのオリジナルのファイルを改名しておいて、utf8に変換したものを活用するようにしたい。

```zsh
mv ~/tmp/40FUKUOK.CSV ~/tmp/40FUKUOK_org.CSV
```

変換を実行するまえに念のために確認

```zsh
nkf --guess ~/tmp/40FUKUOK_org.CSV
Shift_JIS (CRLF)
```

実行例

```zsh
nkf -wLu ~/tmp/40FUKUOK_org.CSV > ~/tmp/40FUKUOK.CSV
```

実行後の確認

```zsh
nkf --guess ~/tmp/40FUKUOK.CSV
UTF-8 (LF)
```
