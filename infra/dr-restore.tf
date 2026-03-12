resource "aws_db_instance" "restore_db" {
  provider = aws.dr

  identifier          = "dr-restored-db"
  snapshot_identifier = aws_db_snapshot_copy.dr_copy.id
  instance_class      = "db.t3.micro"
  engine              = "postgres"
  publicly_accessible = false

  tags = {
    Name = "DR-RDS-Restore"
  }
}