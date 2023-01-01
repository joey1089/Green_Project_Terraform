# Terraform required provider block
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.22"
    }
  }
  required_version = ">= 0.2.1"
}

provider "aws" {
  region = "us-east-1"
}

#create default VPC
resource "aws_default_vpc" "default" {
  tags = {
    Name = "Default VPC"
  }
}

#create subnet for each VPC
# public subnet 1
resource "aws_default_subnet" "public_subnet1" {
  
  
  availability_zone = "us-east-1a"

  tags = {
    name = "public_subnet1"
  }
}

# public subnet 2
resource "aws_default_subnet" "public_subnet2" {
  
  
  availability_zone = "us-east-1b"

  tags = {
    name = "public_subnet2"
  }
}
# private subnet 1
resource "aws_default_subnet" "private_subnet1" {
  
  
  availability_zone = "us-east-1c"

  tags = {
    name = "private_subnet1"
  }
}
# private subnet 2
resource "aws_default_subnet" "private_subnet2" { 
   
  availability_zone =  "us-east-1d"

  tags = {
    name = "private_subnet2"
  }
}
# creating internet gateway 
resource "aws_internet_gateway" "igw" {

  tags = {
    name = "igw"
  }
}

# creating route table
# resource "aws_route_table" "rt" {
#   vpc_id = aws_default_vpc.default.id
#   route {    
#     gateway_id = aws_internet_gateway.igw.id
#   }
  
#   # route {
#   #   ipv6_cidr_block        = "::/0"
#   #   egress_only_gateway_id = "aws_internet_gateway.igw"
#   # }


#   tags = {
#     name = "rt"
#   }
# }
resource "aws_default_route_table" "default_rt" {
  default_route_table_id =  aws_default_vpc.default.default_route_table_id
  # aws_vpc.example.default_route_table_id

  route = []

  # route {
  #   # cidr_block = "10.0.1.0/24"
  #   gateway_id = "aws_internet_gateway.igw"
  # }


  tags = {
    Name = "default_rt"
  }
}

# associate route table to the public subnet 1
resource "aws_route_table_association" "public_rt1" {
  subnet_id      = aws_default_subnet.public_subnet1.id
  route_table_id = aws_default_route_table.default_rt.id
}

# associate route table to the public subnet 2
resource "aws_route_table_association" "public_rt2" {
  subnet_id      = aws_default_subnet.public_subnet2.id
  route_table_id = aws_default_route_table.default_rt.id
}

# associate route table to the private subnet 1
resource "aws_route_table_association" "private_rt1" {
  subnet_id      = aws_default_subnet.private_subnet1.id
  route_table_id = aws_default_route_table.default_rt.id
}
# associate route table to the private subnet 2
resource "aws_route_table_association" "private_rt2" {
  subnet_id      = aws_default_subnet.private_subnet2.id
  route_table_id = aws_default_route_table.default_rt.id
}
