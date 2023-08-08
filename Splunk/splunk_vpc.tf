# awsプロバイダの設定
provider "aws" {
  region = "ap-northeast-1"
}

# 自端末のパブリックIPを取得
data "http" "my_public_ip" {
  url = "https://ipv4.icanhazip.com/"
}

# 自端末のパブリックIP（CIDR形式）
locals {
  my_public_ip_cidr = "${trimspace(data.http.my_public_ip.response_body)}/32"
}

# Splunk用VPC
resource "aws_vpc" "splunk_vpc" {
  cidr_block           = "10.1.0.0/16"
  enable_dns_hostnames = true
}

# Splunk用サブネット
resource "aws_subnet" "splunk_subnet" {
  vpc_id                  = aws_vpc.splunk_vpc.id
  cidr_block              = "10.1.1.0/24"
  availability_zone       = "ap-northeast-1a"
  map_public_ip_on_launch = true
}

# Splunk用インターネットゲートウェイ
resource "aws_internet_gateway" "splunk_igw" {
  vpc_id = aws_vpc.splunk_vpc.id
}

# Splunk用ルートテーブル
resource "aws_route_table" "splunk_rtb" {
  vpc_id = aws_vpc.splunk_vpc.id

    route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.splunk_igw.id
  }
}

# サブネットにSplunk用ルートテーブルを紐づけ
resource "aws_route_table_association" "splunk_rt_assoc" {
  subnet_id      = aws_subnet.splunk_subnet.id
  route_table_id = aws_route_table.splunk_rtb.id
}

# Splunk用セキュリティグループの作成
resource "aws_security_group" "splunk_sg" {
  name   = "splunk-sg"
  vpc_id = aws_vpc.splunk_vpc.id

  ingress {
    from_port   = 22 # SSH
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [local.my_public_ip_cidr]
  }

  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = [local.my_public_ip_cidr] # Splunk Webのデフォルトポートを許可
  }

    ingress {
    from_port   = 9997
    to_port     = 9997
    protocol    = "tcp"
    cidr_blocks = ["10.0.1.0/24"] # Universal Forwarderの許可
  }

  ingress {
    from_port   = 8088
    to_port     = 8088
    protocol    = "tcp"
    cidr_blocks = ["10.0.1.0/24"] # HTTP Event Collectorの許可
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}