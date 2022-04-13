# zsearch-api

郵便番号から住所を検索するコマンドラインアプリ

## Setup

事前に`plenv`を使えるようにしておき指定バージョンのPerlを使えるように

git clone にてソースコードを配置後プロジェクト配下にてモジュールをインストール

```zsh
./cpanm -l ./local --installdeps .
```

## Work

ローカル開発時の起動方法など

app サーバー起動の場合

```zsh
perl -I ./local/lib/perl5 ./local/bin/morbo -l "http://*:3010" ./script/app
```

リクエスト

```zsh
curl 'http://localhost:3010/'
```

cgi ファイルを起動の場合

```zsh
python3 -m http.server 3010 --cgi
```

リクエスト

```zsh
curl 'http://localhost:3010/cgi-bin/index.cgi'
```

コマンドラインによる起動

```zsh
./script/zsearch
```

詳細は[doc/](doc/)を参照

公開環境へ公開

```sh
ssh becom2022@becom2022.sakura.ne.jp
cd ~/www/zsearch-api
git fetch && git checkout main && git pull
```

## Usage

### CLI

```text
zsearch <resource> <method> [--params=<JSON>]

  <resource>  Specify each resource name
  <method>    Specify each method name
  --params    Json format with reference to request parameters

Specify the resource name as the first argument
Specify the method name as the second argument
Format command line interface options in json format

第一引数はリソース名を指定
第二引数はメソッド名を指定
コマンドラインインターフェスのオプションはjson形式で整形してください
```

### HTTP

```text
POST https://zsearch-api.becom.co.jp/

http request requires apikey
All specifications should be included in the post request parameters
See Examples in each document for usage

http リクエストには apikey の指定が必要
全ての指定は post リクエストのパラメーターに含めてください
使用法は各ドキュメントの Example を参照
```

### Resource

See here for details: [doc/](doc/)

```text
build     Environment
search    Search for zip code information
```

## Memo

sqlite-simple についてはしばらくはダウンロード対応

```zsh
cp ~/Downloads/SQLite-Simple-main/lib/SQLite/Simple.pm ~/github/zsearch-api/lib/SQLite
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

郵便局の web サイトから郵便番号データダウンロードをおこなう

- 郵便番号データダウンロード
  - <https://www.post.japanpost.jp/zipcode/download.html>
- 読み仮名データの促音・拗音を小書きで表記するもの(zip 形式)
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

- 文字コードは utf8 に整え、改行コードは LF
  - nkf を活用して処理
  - nkf は入力側のテキストの文字コードは自動判定してくれる

homebrew を使った入手

```zsh
brew install nkf
```

ダウンロードのオリジナルのファイルを改名しておいて、utf8 に変換したものを活用するようにしたい。

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
