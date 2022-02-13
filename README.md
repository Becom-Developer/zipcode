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
zsearch --params'{}'
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
  "messege": "検索件数: 90",
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
