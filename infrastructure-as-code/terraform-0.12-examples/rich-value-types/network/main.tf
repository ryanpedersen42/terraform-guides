resource "aws_vpc" "my_vpc" {
  cidr_block = var.network_config.vpc_cidr
  tags = {
    Name = var.network_config.vpc_name
  }
}

resource "aws_subnet" "my_subnet" {
  vpc_id = aws_vpc.my_vpc.id
  cidr_block = var.network_config.subnet_cidr
  tags = {
    # Drata: Configure [aws_subnet.tags] to ensure that organization-wide tagging conventions are followed.
    Name = var.network_config.subnet_name
  }
}
