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
