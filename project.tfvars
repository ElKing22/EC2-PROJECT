resource "aws_vpc" "Prod-rock-VPC" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"
  enable_dns_hostnames = true
  enable_dns_support   = true


  tags = {
    Name = "Prod-rock-VPC"
  }
}
resource "aws_subnet" "Test-public-sub1" {
  vpc_id     = aws_vpc.Prod-rock-VPC.id
  cidr_block = "10.0.4.0/24"

  tags = {
    Name = "Test-public-sub1"
  }
}

resource "aws_subnet" "Test-public-sub2" {
  vpc_id     = aws_vpc.Prod-rock-VPC.id
  cidr_block = "10.0.3.0/24"

  tags = {
    Name = "Test-public-sub2"
  }
}

resource "aws_subnet" "Test-private-sub1" {
  vpc_id     = aws_vpc.Prod-rock-VPC.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "Test-private-sub1"
  }
}

resource "aws_subnet" "Test-private-sub2" {
  vpc_id     = aws_vpc.Prod-rock-VPC.id
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "Test-private-sub2"
  }

}

resource "aws_route_table" "Test-public-route" {
  vpc_id = aws_vpc.Prod-rock-VPC.id
tags = {
    Name = "Test-public-route-table"
  }
}
resource "aws_route_table" "Test-private-route-table" {
  vpc_id = aws_vpc.Prod-rock-VPC.id
tags = {
    Name = "Test-private-route-table"
  }
}
resource "aws_route_table_association" "private-route-1-ssociation" {
  subnet_id      = aws_subnet.Test-public-sub1.id
  route_table_id = aws_route_table.Test-public-route.id
}

resource "aws_route_table_association" "public-route-1-ssociation" {
  subnet_id      = aws_subnet.Test-public-sub1.id
  route_table_id = aws_route_table.Test-public-route.id
}

resource "aws_internet_gateway" "IGW" {
  vpc_id = aws_vpc.Prod-rock-VPC.id

  tags = {
    Name = "IGW"
  }
}

resource "aws_route" "public-IGW-route" { 
  route_table_id            = aws_route_table.Test-public-route.id 
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id                = aws_internet_gateway.IGW.id
}

  resource "aws_eip" "Test-EIP" {
  vpc      = true
}

resource "aws_nat_gateway" "Test-EIP" {
  allocation_id = aws_eip.Test-EIP.id
  subnet_id     = aws_subnet.Test-public-sub1.id

}
    
 resource "aws_nat_gateway" "Test-EIP1" {
  connectivity_type = "private"
  subnet_id         = aws_subnet.Test-private-sub1.id

}

  resource "aws_security_group" "launch-wizard-1"  {
   description = "Allow HTTP and SSH inbound traffic"
  vpc_id      = aws_vpc.Prod-rock-VPC.id

   ingress {

    description      = "TLS from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]

  }
  
  ingress {

    description      = "TLS from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]

  }

 egress {

    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]

  }

  tags = {
  Name ="allow_HTTP"

  }


}

resource "aws_instance" "EC2" {
  ami                     = "ami-0f540e9f488cfa27d" # eu-west-2
  instance_type           = "t2.micro"
  key_name                =  "Kingkey"
  subnet_id               = aws_subnet.Test-private-sub1.id
  
}


resource "aws_instance" "EC2-1" {
  ami                     = "ami-0f540e9f488cfa27d" # eu-west-2
  instance_type           = "t2.micro"
  key_name                =  "Kingkey"
  subnet_id               = aws_subnet.Test-public-sub1.id
}
