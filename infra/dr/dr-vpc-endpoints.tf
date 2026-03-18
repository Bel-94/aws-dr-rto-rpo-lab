resource "aws_security_group" "dr_vpc_endpoints" {
  provider = aws.dr

  name   = "${local.name_prefix}-dr-vpce-sg"
  vpc_id = aws_vpc.dr.id

  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    cidr_blocks     = [aws_vpc.dr.cidr_block]
  }

  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.dr_app.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_vpc_endpoint" "dr_ecr_api" {
  provider            = aws.dr
  vpc_id              = aws_vpc.dr.id
  service_name        = "com.amazonaws.us-west-2.ecr.api"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.dr_private_app[*].id
  security_group_ids  = [aws_security_group.dr_vpc_endpoints.id]
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "dr_ecr_dkr" {
  provider            = aws.dr
  vpc_id              = aws_vpc.dr.id
  service_name        = "com.amazonaws.us-west-2.ecr.dkr"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.dr_private_app[*].id
  security_group_ids  = [aws_security_group.dr_vpc_endpoints.id]
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "dr_secretsmanager" {
  provider            = aws.dr
  vpc_id              = aws_vpc.dr.id
  service_name        = "com.amazonaws.us-west-2.secretsmanager"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.dr_private_app[*].id
  security_group_ids  = [aws_security_group.dr_vpc_endpoints.id]
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "dr_logs" {
  provider            = aws.dr
  vpc_id              = aws_vpc.dr.id
  service_name        = "com.amazonaws.us-west-2.logs"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.dr_private_app[*].id
  security_group_ids  = [aws_security_group.dr_vpc_endpoints.id]
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "dr_s3" {
  provider          = aws.dr
  vpc_id            = aws_vpc.dr.id
  service_name      = "com.amazonaws.us-west-2.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [aws_route_table.dr_private_app.id]
}
