# Build

環境構築

CLI

```text
zserch build <method> [--params=<JSON>]

    <method>    Specify each method name
    --params    Json format with reference to request parameters
```

HTTP

```text
No function is provided
機能は提供されません
```

Method

```text
init        Database initialization
insert      Read csv data
dump        Eject database data
restore     Rebuild database
```

## Example

### Build init

データベース初期化

Request parameters

```json
{}
```

or

実行時に任意のファイル名を指定する場合

```json
{"name":"sample-stg.db"}
```

Response parameters

```json
{"message":"build success sample.db"}
```

CLI

```zsh
beauth build init
```

### Build insert

csv データからデータを復元

Request parameters

```json
{
  "csv": "/full/path/sample.csv",
  "table": "post",
  "cols": [
    "local_code",    "zipcode_old",
    "zipcode",       "pref_kana",
    "city_kana",     "town_kana",
    "pref",          "city",
    "town",          "double_zipcode",
    "town_display",  "city_block_display",
    "double_town",   "update_zipcode",
    "update_reason", "deleted",
    "created_ts",    "modified_ts"
  ],
  "time_stamp": [ "created_ts", "modified_ts" ],
  "rewrite": { "deleted": 0 }
}
```

Response parameters

```json
{"message":"insert success sample.csv"}
```

CLI

```zsh
beauth build insert --params='{}'
```

### Build dump

データベースのデータを排出

Request parameters

```json
{}
```

Response parameters

```json
{"message":"dump success sample.dump"}
```

CLI

```zsh
beauth build dump
```

### Build restore

ダンプデータからデータベースを再構築する

Request parameters

```json
{}
```

Response parameters

```json
{"message":"restore success sample.db"}
```

CLI

```zsh
beauth build restore
```
