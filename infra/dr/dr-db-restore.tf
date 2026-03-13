resource "aws_db_subnet_group" "dr" {
  provider = aws.dr

  name       = "${local.name_prefix}-dr-db-subnet"
  subnet_ids = aws_subnet.dr_private_db[*].id
}

resource "aws_db_instance" "dr_restore" {
  provider = aws.dr

  identifier          = "${local.name_prefix}-dr-postgres"
  snapshot_identifier = aws_db_snapshot_copy.dr_copy.id

  instance_class = "db.t3.micro"
  engine         = "postgres"

  db_subnet_group_name   = aws_db_subnet_group.dr.name
  vpc_security_group_ids = [aws_security_group.dr_db.id]

  publicly_accessible = false
}