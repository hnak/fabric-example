
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