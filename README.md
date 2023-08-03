# aws-webdav

## はじめに
Workshop対応用に、WebDAV付きのファイルサーバを自動で構築するものです。
AWS環境が必須になります。Cloud Practitioner取りましょう！

## 構成
### fileserver
AWS上にApacheファイルサーバを構築します。
ファイルアップロードは**terraformを実行した端末（≒自端末）からのみ実施可能**です。
SSHしてファイルを置いていただいてもいいですが、WebDAVが立っているので端末からファイルを直接アップロード可能です。

### Splunk
無視してください。

## 使い方
Cloneして実行するだけです。Secret Access Keyなんかは事前に設定ください。
