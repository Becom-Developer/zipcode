# Grecaptcha

google reCAPTCHA 判定

CLI

```text
zsearch grecaptcha <method> [--params=<JSON>]

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
siteverify    recaptcha api siteverify
```

## Example

### Grecaptcha siteverify

google recaptcha api siteverify を実行

- <https://developers.google.com/recaptcha/docs/verify>

Request parameters

```json
{
  "secret": "6LcivDEjAAAAAOxO0_k4VwMJ4_",
  "response": "03AEkXODDH6jrUfANvX5rMvt6LkkEI8yonAIk-H56_",
  "remoteip": "127.0.0.1"
}
```

or

```json
{
  "response": "03AEkXODDH6jrUfANvX5rMvt6LkkEI8yonAIk-H56_"
}
```

- `secret`
  - `If omitted, the private key set on the server side will be used.`
  - 省略時はサーバ側で設定されているシークレットキーを使用

Response parameters

```json
{
  "success": true|false,
  "challenge_ts": timestamp,  // timestamp of the challenge load (ISO format yyyy-MM-dd'T'HH:mm:ssZZ)
  "hostname": string,         // the hostname of the site where the reCAPTCHA was solved
  "error-codes": [...]        // optional
}
```

- `google recaptcha api return it as it is.`
- recaptcha api のレスポンスをそのまま返却

CLI

```zsh
zsearch grecaptcha siteverify --params='{}'
```
