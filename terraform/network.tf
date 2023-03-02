resource "aws_internet_gateway" "default" {
  vpc_id = aws_vpc.dev-env.id
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.dev-env.id
}

resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  gateway_id             = aws_internet_gateway.default.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table_association" "public-web" {
  route_table_id = aws_route_table.public.id
  subnet_id      = aws_subnet.public-web.id
}

# vpc
resource "aws_vpc" "dev-env" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = "true"
  enable_dns_hostnames = "false"
  tags = {
    Name = "dev-env"
  }
}

# subnet
## public
resource "aws_subnet" "public-web" {
    vpc_id = "${aws_vpc.dev-env.id}"
    cidr_block = "10.0.1.0/24"
    availability_zone = "ap-northeast-1a"
    tags = {
      Name = "public-web"
    }
}

## private
resource "aws_subnet" "private-db1" {
  vpc_id            = aws_vpc.dev-env.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "ap-northeast-1a"
  tags = {
    Name = "private-db1"
  }
}

resource "aws_subnet" "private-db2" {
    vpc_id = "${aws_vpc.dev-env.id}"
    cidr_block = "10.0.3.0/24"
    availability_zone = "ap-northeast-1c"
    tags = {
      Name = "private-db2"
    }
}