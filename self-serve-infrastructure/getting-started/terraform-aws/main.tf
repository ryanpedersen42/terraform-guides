provider "aws" {
  region = "${var.region}"
}

resource "aws_vpc" "demo_vpc" {
  cidr_block = "${var.vpc_cidr_block}"

  tags {
    Name = "fp_demo_vpc"
  # Drata: Configure [aws_vpc.tags] to ensure that organization-wide tagging conventions are followed.
  }
}

resource "aws_subnet" "demo_subnet" {
  vpc_id            = "${aws_vpc.demo_vpc.id}"
  cidr_block        = "${var.subnet_cidr_block}"
  availability_zone = "${var.subnet_availability_zone}"

  tags {
    Name = "fp_demo_subnet"
  # Drata: Configure [aws_subnet.tags] to ensure that organization-wide tagging conventions are followed.
  }
}
