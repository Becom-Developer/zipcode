# Search

郵便番号情報を検索

```text
郵政省が提供している郵便番号データをもとに構築
郵便番号および住所の情報から該当情報を検索
```

CLI

```text
zsearch search <method> [--params=<JSON>]

    <method>    Specify each method name
    --params    Json format with reference to request parameters
```

HTTP

```text
POST https://zsearch-api.becom.co.jp/

See example for usage
使用法は Example を参照
```

Method

```text
like    Ambiguous search
```

## Example

### Search like

あいまいな検索

```text
検索ワードを前方一致検索
```

Request parameters

```json
{"code":"812","pref":"福岡","city":"福岡","town":"吉"}
```

Response parameters

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

HTTP

```zsh
curl 'https://zsearch-api.becom.co.jp/' \
--verbose \
--header 'Content-Type: application/json' \
--header 'accept: application/json' \
--data-binary '{"resource":"search","method":"like","apikey":"becom","params":{}}'
```

CLI

```zsh
zsearch search like --params='{}'
```
