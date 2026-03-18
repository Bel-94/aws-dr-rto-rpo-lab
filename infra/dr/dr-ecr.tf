resource "aws_ecr_repository" "dr_app" {
  provider             = aws.dr
  name                 = "${local.name_prefix}-app"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "${local.name_prefix}-dr-ecr"
  }
}

output "dr_ecr_repository_url" {
  value = aws_ecr_repository.dr_app.repository_url
}
