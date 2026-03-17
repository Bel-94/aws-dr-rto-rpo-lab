resource "aws_vpc" "dr" {
  provider = aws.dr

  cidr_block           = "10.10.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${local.name_prefix}-dr-vpc"
  }
}

resource "aws_internet_gateway" "dr" {
  provider = aws.dr
  vpc_id   = aws_vpc.dr.id

  tags = {
    Name = "${local.name_prefix}-dr-igw"
  }
}

resource "aws_subnet" "dr_public" {
  provider = aws.dr
  count    = 2

  vpc_id                  = aws_vpc.dr.id
  cidr_block              = cidrsubnet("10.10.0.0/16", 8, count.index)
  availability_zone       = "us-west-2${["a", "b"][count.index]}"
  map_public_ip_on_launch = true

  tags = {
    Name = "${local.name_prefix}-dr-public-${count.index}"
  }
}

resource "aws_subnet" "dr_private_app" {
  provider = aws.dr
  count    = 2

  vpc_id            = aws_vpc.dr.id
  cidr_block        = cidrsubnet("10.10.0.0/16", 8, count.index + 10)
  availability_zone = "us-west-2${["a", "b"][count.index]}"

  tags = {
    Name = "${local.name_prefix}-dr-private-app-${count.index}"
  }
}

resource "aws_subnet" "dr_private_db" {
  provider = aws.dr
  count    = 2

  vpc_id            = aws_vpc.dr.id
  cidr_block        = cidrsubnet("10.10.0.0/16", 8, count.index + 20)
  availability_zone = "us-west-2${["a", "b"][count.index]}"

  tags = {
    Name = "${local.name_prefix}-dr-private-db-${count.index}"
  }
}
