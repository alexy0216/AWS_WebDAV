# awsプロバイダの設定
provider "aws" {
  region = "ap-northeast-1"
}

# HTTPプロバイダの設定
provider "http" {}

# 自端末のパブリックIPを取得
data "http" "my_public_ip" {
  url = "https://ipv4.icanhazip.com/"
}

# 自端末のパブリックIP（CIDR形式）
locals {
  my_public_ip_cidr = "${trimspace(data.http.my_public_ip.response_body)}/32"
}

# ファイルサーバ用VPCの作成
resource "aws_vpc" "fileserver_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
}

# パブリックサブネットの作成
resource "aws_subnet" "fileserver_subnet" {
  vpc_id                  = aws_vpc.fileserver_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-northeast-1a"
  map_public_ip_on_launch = true
}

# インターネットゲートウェイの作成
resource "aws_internet_gateway" "fileserver_igw" {
  vpc_id = aws_vpc.fileserver_vpc.id
}

# ルートテーブルの作成
resource "aws_route_table" "fileserver_rtb" {
  vpc_id = aws_vpc.fileserver_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.fileserver_igw.id
  }
}

# サブネットにルートテーブルを紐づけ
resource "aws_route_table_association" "fileserver_rt_assoc" {
  subnet_id      = aws_subnet.fileserver_subnet.id
  route_table_id = aws_route_table.fileserver_rtb.id
}

# セキュリティグループの作成
resource "aws_security_group" "fileserver_sg" {
  name   = "fileserver-sg"
  vpc_id = aws_vpc.fileserver_vpc.id

  ingress {
    from_port   = 22 # SSH
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [local.my_public_ip_cidr]
  }

  ingress {
    from_port   = 80 # HTTP
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [local.my_public_ip_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}