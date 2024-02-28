provider "aws" {
  region = "ca-central-1"
}

resource "aws_vpc" "aws_with_terraform_vpc" {
  cidr_block = "10.0.0.0/16"


 tags = {
    Project = "aws_with_terraform"
  }
}
resource "aws_eip" "my_eip" {
  vpc      = true
  tags = {
    Name    = "MyEIP"
    Project = "aws_with_terraform"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.aws_with_terraform_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "ca-central-1a"
}

resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.aws_with_terraform_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "ca-central-1a"
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.aws_with_terraform_vpc.id


    route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }


  tags = {
    Project = "aws_with_terraform"
    Name = "PublicRouteTable"
  }
}

resource "aws_route_table_association" "public_subnet_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.aws_with_terraform_vpc.id


  tags = {
    Project = "aws_with_terraform"
    Name = "MyIGW"
  }
}

resource "aws_nat_gateway" "my_nat_gateway" {
  allocation_id = aws_eip.my_eip.id
  subnet_id     = aws_subnet.public_subnet.id


  tags = {
    Project = "aws_with_terraform"
    Name = "MyNATGateway"
  }
}


resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.aws_with_terraform_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.my_nat_gateway.id
  }

  tags = {
    Project = "aws_with_terraform"
    Name = "PrivateRouteTable"
  }
}

resource "aws_route_table_association" "private_subnet_association" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_route_table.id
}
