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
{ "zipcode": "812", "pref": "福岡", "city": "福岡", "town": "吉" }
```

or

```json
{
  "zipcode": "812",
  "pref": "福岡",
  "city": "福岡",
  "town": "吉",
  "output": "simple"
}
```

Response parameters

```json
{
  "data": [
    {
      "created_ts": "2022-02-17 17:07:47",
      "town_kana": "ヨシヅカ",
      "update_reason": "0",
      "local_code": "40132",
      "town_display": "0",
      "pref_kana": "フクオカケン",
      "city": "福岡市博多区",
      "deleted": 0,
      "zipcode_old": "812  ",
      "modified_ts": "2022-02-17 17:07:47",
      "city_kana": "フクオカシハカタク",
      "id": 112390,
      "double_town": "0",
      "double_zipcode": "0",
      "pref": "福岡県",
      "town": "吉塚",
      "update_zipcode": "0",
      "city_block_display": "1",
      "zipcode": "8120041"
    }
    // { ... }
  ],
  "message": "検索件数: 2",
  "version": "2022-04-28",
  "count": 2
}
```

or

```text
8120041 福岡県福岡市博多区吉塚
8120046 福岡県福岡市博多区吉塚本町
検索件数: 2
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
