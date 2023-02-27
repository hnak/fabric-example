terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }

  required_version = ">= 1.0.0"
}

# Variable
variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "region" {
    default = "ap-northeast-1"
}

# Provider
provider "aws" {
    access_key = var.aws_access_key
    secret_key = var.aws_secret_key
    region = "ap-northeast-1"
  default_tags {
    tags = {
      Managed = "terraform"
    }
  }
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

# Security Group
resource "aws_security_group" "public-web-sg" {
    name = "public-web-sg"
    vpc_id = "${aws_vpc.dev-env.id}"
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

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
      Name = "public-db-sg"
    }
}

# RDS
resource "aws_db_subnet_group" "private-db" {
  name       = "private-db"
  subnet_ids = ["${aws_subnet.private-db1.id}", "${aws_subnet.private-db2.id}"]
  tags = {
    Name = "private-db"
  }
}

resource "aws_db_instance" "test-db" {
  identifier             = "test-db"
  allocated_storage      = 20
  engine                 = "postgres"
  engine_version         = "15.2"
  instance_class         = "db.t3.micro"
  name                   = "testdb"
  username               = "myuser"
  password               = "mypassword"
  vpc_security_group_ids = ["${aws_security_group.private-db-sg.id}"]
  db_subnet_group_name   = aws_db_subnet_group.private-db.name
  skip_final_snapshot    = true
}

resource "aws_ecr_repository" "fabric-ca" {
  name                 = "fabric-ca"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_cloudwatch_log_group" "fabric-ca" {
  name              = "/ecs/project/dev/fabric-ca"
  retention_in_days = 30
}