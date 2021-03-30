resource "aws_vpc" "kbn_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
}

resource "aws_subnet" "kbn_subnet" {
  vpc_id     = aws_vpc.kbn_vpc.id
  cidr_block = "10.0.0.0/24"
}

resource "aws_internet_gateway" "kbn_ig" {
  vpc_id = aws_vpc.kbn_vpc.id
}

resource "aws_route_table" "kbn_rt" {
  vpc_id = aws_vpc.kbn_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.kbn_ig.id
  }
}

resource "aws_route_table_association" "kbn_rta" {
  subnet_id      = aws_subnet.kbn_subnet.id
  route_table_id = aws_route_table.kbn_rt.id
}
