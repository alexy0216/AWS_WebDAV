# EC2インスタンスの作成
resource "aws_instance" "fileserver_web_server" {
  ami                    = "ami-0e25eba2025eea319" # Amazon Linux 2 Kernel 5.10 AMI 2.0.20230727.0 x86_64 HVM gp2
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.fileserver_subnet.id
  vpc_security_group_ids = [aws_security_group.fileserver_sg.id]

  key_name = "fs_id_rsa" # SSH接続用のキーペアの名前

  user_data = <<-EOF
  #! /bin/bash
  sudo timedatectl set-timezone Asia/Tokyo
  sudo localectl set-locale LANG=ja_JP.utf8
  source /etc/locale.conf
  sudo yum install -y httpd mod_dav_fs
  sudo mkdir -p /var/lib/dav
  sudo chown -R apache:apache /var/lib/dav
  sudo systemctl start httpd
  sudo systemctl enable httpd
  sudo mkdir /var/www/html/webdav
  sudo chown -R apache:apache /var/www/html/webdav
  echo 'Alias /webdav /var/www/html/webdav' | sudo tee -a /etc/httpd/conf.d/webdav.conf
  echo 'DAVLockDB /var/lib/dav/lockdb' | sudo tee -a /etc/httpd/conf.d/webdav.conf
  echo '<Directory /var/www/html/webdav>' | sudo tee -a /etc/httpd/conf.d/webdav.conf
  echo '    DAV On' | sudo tee -a /etc/httpd/conf.d/webdav.conf
  echo '    AuthType None' | sudo tee -a /etc/httpd/conf.d/webdav.conf
  echo '    Require all granted' | sudo tee -a /etc/httpd/conf.d/webdav.conf
  echo '</Directory>' | sudo tee -a /etc/httpd/conf.d/webdav.conf
  sudo systemctl restart httpd
EOF


}