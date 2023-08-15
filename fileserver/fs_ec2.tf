# ！変更推奨！パスワード（ハッシュ値）
variable "encoded_password" {
  default = ":$2y$10$H56m.GlpN3F1VzQpSC9zoefQtyTNdqA.Z0wExeU9p7qWzefNixv1i"  # htpasswd -bnBC 10 "" password の結果を設定
}

# EC2インスタンスの作成
resource "aws_instance" "fileserver_web_server" {
  ami                    = "ami-044dbe71ee2d3c59e" # Amazon Linux 2 Kernel 5.10 AMI 2.0.20230808.0 x86_64 HVM gp2
  # ami                    = "ami-0e25eba2025eea319" # Amazon Linux 2 Kernel 5.10 AMI 2.0.20230727.0 x86_64 HVM gp2
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.fileserver_subnet.id
  vpc_security_group_ids = [aws_security_group.fileserver_sg.id]

  key_name = "fs_id_rsa" # SSH接続用のキーペアの名前

  user_data = <<-EOF
  #! /bin/bash
  sudo yum update -y
  sudo yum install man-pages-ja -y
  sudo timedatectl set-timezone Asia/Tokyo
  sudo localectl set-locale LANG=ja_JP.UTF-8
  source /etc/locale.conf

  # apacheの構築と設定
  sudo yum install -y httpd mod_dav_fs
  sudo mkdir -p /var/lib/dav
  sudo chown -R apache:apache /var/lib/dav
  sudo systemctl start httpd
  sudo systemctl enable httpd
  sudo sed -i 's/AddDefaultCharset UTF-8/AddDefaultCharset Off/' /etc/httpd/conf/httpd.conf

  # webdav.confの設定を追加
  sudo mkdir /var/www/html/webdav
  sudo chown -R apache:apache /var/www/html/webdav
  sudo bash -c 'cat << CONF > /etc/httpd/conf.d/webdav.conf
  Alias /webdav /var/www/html/webdav
  DAVLockDB /var/lib/dav/lockdb
  <Directory /var/www/html/webdav>
    DAV On
    AuthType None
    Require all granted
    </Directory>
  CONF'

  # .htaccessファイルの作成とBasic認証の設定を追加
  sudo bash -c 'cat << CONF > /var/www/html/webdav/.htaccess
  AuthType Basic
  AuthName "Restricted Area"
  AuthUserFile /etc/httpd/.htpasswd
  Require valid-user
  CONF'

  # エンコードされたパスワードを.htpasswdファイルに追加
  echo 'WSuser{var.encoded_password}' | sudo tee -a /etc/httpd/.htpasswd

  # .htaccessを有効化
  # sudo sed -i "/<Directory \"/var/www/html\">/,/</Directory>/ s/AllowOverride None/AllowOverride All/" /etc/httpd/conf/httpd.conf

  sudo systemctl restart httpd

  EOF
}

output "public_ip" {
  value = "Fileserver URL is: http://${aws_instance.fileserver_web_server.public_ip}/webdav"
}
