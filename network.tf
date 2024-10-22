provider "aws" {
  region = var.region
}
resource "aws_vpc" "singapore_vpc" {
  cidr_block = var.vpc_cidr
  }

resource "aws_subnet" "singapore_public_subnet" {
  vpc_id                  = aws_vpc.singapore_vpc.id
  cidr_block              = var.public_subnet_cidr
  map_public_ip_on_launch = true
  availability_zone       = "ap-southeast-1a"
}

resource "aws_subnet" "singapore_private_subnet1" {
  vpc_id            = aws_vpc.singapore_vpc.id
  cidr_block        = var.private_subnet1_cidr
  availability_zone = "ap-southeast-1b"
}

resource "aws_subnet" "singapore_private_subnet2" {
  vpc_id            = aws_vpc.singapore_vpc.id
  cidr_block        = var.private_subnet2_cidr
  availability_zone = "ap-southeast-1c"
}

resource "aws_internet_gateway" "singapore_igw" {
  vpc_id = aws_vpc.singapore_vpc.id
}

resource "aws_route_table" "singapore_public_rt" {
  vpc_id = aws_vpc.singapore_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.singapore_igw.id
  }
}

resource "aws_route_table_association" "public_subnet_assoc" {
  subnet_id      = aws_subnet.singapore_public_subnet.id
  route_table_id = aws_route_table.singapore_public_rt.id
}
