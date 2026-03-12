resource "aws_db_snapshot" "manual_backup" {
  provider               = aws
  db_instance_identifier = aws_db_instance.postgres.identifier
  db_snapshot_identifier = "dr-baseline-dev-manual-snapshot"

  tags = {
    Name = "dr-baseline-dev-manual-snapshot"
  }
}

resource "time_sleep" "wait_for_snapshot" {
  depends_on      = [aws_db_snapshot.manual_backup]
  create_duration = "30s"
}


resource "aws_db_snapshot_copy" "dr_copy" {
  provider                      = aws.dr
  source_db_snapshot_identifier = var.source_snapshot_arn
  target_db_snapshot_identifier = "dr-baseline-dev-dr-copy"

  depends_on = [
    time_sleep.wait_for_snapshot
  ]

  tags = {
    Name = "dr-baseline-dev-dr-snapshot"
  }
}

