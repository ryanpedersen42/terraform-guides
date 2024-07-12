resource "aws_vpc" "main" {
  # Drata: Configure [aws_vpc.tags] to ensure that organization-wide tagging conventions are followed.
  cidr_block           = "${var.vpc_cidr}"
  enable_dns_hostnames = true

  tags {
    Name = "${var.environment_name}"
  }
}
