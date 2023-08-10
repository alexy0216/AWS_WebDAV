# EC2インスタンスの作成
resource "aws_instance" "splunk_server" {
  ami                    = "ami-0e25eba2025eea319" # Amazon Linux 2 Kernel 5.10 AMI 2.0.20230727.0 x86_64 HVM gp2
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.splunk_subnet.id
  vpc_security_group_ids = [aws_security_group.splunk_sg.id]

  key_name = "fs_id_rsa" # SSH接続用のキーペアの名前

  user_data = <<-EOF
  #! /bin/bash
  sudo yum update -y
  sudo yum install man-pages-ja -y
  sudo timedatectl set-timezone Asia/Tokyo
  sudo localectl set-locale LANG=ja_JP.UTF-8
  source /etc/locale.conf
EOF


}

output "public_ip" {
  value = "ec2-user@${aws_instance.splunk_server.public_ip}"
}
