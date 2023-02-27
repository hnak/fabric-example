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
