
# Security Group
resource "aws_security_group" "public-web-sg" {
    name = "public-web-sg"
    vpc_id = "${aws_vpc.dev-env.id}"
    # ingress {
    #     from_port = 22
    #     to_port = 22
    #     protocol = "tcp"
    #     cidr_blocks = ["0.0.0.0/0"]
    # }

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    tags = {
      Name = "public-web-sg"
    }
}

resource "aws_security_group" "private-db-sg" {
    name = "private-db-sg"
    vpc_id = "${aws_vpc.dev-env.id}"
    ingress {
        from_port = 5432
        to_port = 5432
        protocol = "tcp"
        cidr_blocks = ["10.0.1.0/24"]
    }
    tags = {
      Name = "private-db-sg"
    }
}
