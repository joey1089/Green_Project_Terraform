# Using default VPC - 
# hint - default VPC does not allow cider block - terraform destroy cmd doesn't remove the default vpc but 
# removes security group if conflict arises
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
# public subnet 3
resource "aws_default_subnet" "public_subnet3" {
  availability_zone = "us-east-1c"
  tags = {
    name = "public-subnet3"
  }
}

# creating internet gateway 
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_default_vpc.default.id
  tags = {
    name = "igw"
  }
}

resource "aws_route_table" "igw_public_rt" {
  vpc_id = aws_default_vpc.default.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "Route Table"
  }
}
# associate route table to the public subnet 1
resource "aws_route_table_association" "public_rt1" {
  subnet_id      = aws_default_subnet.public_subnet1.id
  route_table_id = aws_route_table.igw_public_rt.id
}

# associate route table to the public subnet 2
resource "aws_route_table_association" "public_rt2" {
  subnet_id      = aws_default_subnet.public_subnet2.id
  route_table_id = aws_route_table.igw_public_rt.id
}
# associate route table to the public subnet 3
resource "aws_route_table_association" "public_rt3" {
  subnet_id      = aws_default_subnet.public_subnet3.id
  route_table_id = aws_route_table.igw_public_rt.id
}

# create security group allowing ssh and http 
resource "aws_security_group" "web_sg" {
  name        = "http_ssh_sg"
  description = "allow HTTP and SSH access only on ingress"
  vpc_id      = aws_default_vpc.default.id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  #Allow all outgoing
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# # create application load balancer - external
# resource "aws_lb" "test" {
#   name               = "test-lb-tf"
#   internal           = false
#   load_balancer_type = "application"
#   security_groups    = [aws_security_group.lb_sg.id]
#   subnets            = [for subnet in aws_default_vpc.default.id : subnet.id]
# }

#Create ec2 instances_1
resource "aws_instance" "ec2_instance_1" {
  ami                = "ami-0b5eea76982371e91"
  instance_type      = "t2.micro"
  subnet_id          = aws_default_subnet.public_subnet1.id
  # security_groups = [aws_security_group.http_allow_sg.id]
  security_groups = [ aws_security_group.web_sg.id ]  
  user_data          = file("user-data.sh")
  tags = {
    name = "ec2_instance_1"
  }
}
#Create ec2 instances_2
resource "aws_instance" "ec2_instance_2" {
  ami                = "ami-0b5eea76982371e91"
  instance_type      = "t2.micro"
  subnet_id          = aws_default_subnet.public_subnet1.id
  # security_groups = [aws_security_group.http_allow_sg.id]
  security_groups = [ aws_security_group.web_sg.id ]  
  user_data          = file("user-data.sh")
  tags = {
    name = "ec2_instance_2"
  }
}

#Create ec2 instances_3
resource "aws_instance" "ec2_instance_3" {
  ami                = "ami-0b5eea76982371e91"
  instance_type      = "t2.micro"
  subnet_id          = aws_default_subnet.public_subnet1.id
  # security_groups = [aws_security_group.http_allow_sg.id]
  security_groups = [ aws_security_group.web_sg.id ]  
  user_data          = file("user-data.sh")
  tags = {
    name = "ec2_instance_3"
  }
}


