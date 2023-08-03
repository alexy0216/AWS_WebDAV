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
セキュリティ設定などはザルですし、自端末からしかアクセスできずt2microで使い回すにはきついサイズなので、基本的には使い終わったら都度壊す運用を想定しています。
以下手順は山村先生の「o11y WS環境準備方法」ファイルからのパクリです。

### 事前準備
MacOS：
gitとterraformをbrewでインストールしてください。

Windows：
WSL2でLinux環境をWindowsにインストールするのが一番楽だと思います。
Linuxでパッケージマネージャーを使いgitとterraformをインストールしてください。

AWSのクレデンシャル：
1. IAM > ユーザー
2. 自分用のユーザーを作成
   権限は「AdministratorAccess」
3. [認証情報]から[アクセスキーの作成]をクリックしアクセスキーIDとシークレットアクセスキーを入手

### EC2のデプロイ
gitを使用する際にはZScalerはoffにしてください。さもなければエラーがでます。

以下をコマンドラインで実行

(初回のみ)
git clone https://github.com/alexy0216/AWS_WebDAV.git

cd aws-webdav/fileserver
git pull
terraform init -upgrade

(初回のみ)
terraform workspace new <分かりやすいworkspace名 (ws-fileserver、とか) >

export AWS_ACCESS_KEY_ID="<アクセスキーID>"
export AWS_SECRET_ACCESS_KEY="<シークレットアクセスキー>"

（一応実行してエラーが出ないのを確認）
terraform plan

terraform apply

ざざーとテキストが流れたあと、これで作るか？と聞かれるので yes と入力します。

### WebDAVの設定
（SSHしてSCPでファイルを置く人は不要です）
MacOSならFinderで設定できるはずなのですがなんだか上手くいかないので、代わりに
https://cyberduck.io/
を使うと楽ちんです。Windows版もある模様ですが、Windowsならエクスプローラで設定できるかもしれません。

Cyberduckを使う場合:
新規接続 > WebDAV (HTTP)に変更 > サーバにブラウザから取ってきた"http://[IPアドレス]/webdav"をペースト > Anonymousログインにチェックして接続をクリック
* サーバは手打ちだとうまくいきません。
後はフォルダを作ってファイルをD&Dするだけです。セービングスローに打ち勝ちましょう。
なお2バイト文字が文字化けします。誰か助けてください。

### WS終了後
cd aws-webdav/fileserver
export AWS_ACCESS_KEY_ID="<アクセスキーID>"
export AWS_SECRET_ACCESS_KEY="<シークレットアクセスキー>"
terraform destroy

ざざーとテキストが流れたあと、ほんとに壊すの？と聞かれるので yes と入力します。

以上です。お疲れ様でした。
