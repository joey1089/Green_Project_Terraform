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
data "aws_availability_zones" "available" {}
# main VPC block
resource "aws_vpc" "main_vpc" {
  cidr_block = "10.10.0.0/16"
  tags = {
    Name = "main-VPC"
  }
}

# associate resource for public subnets
resource "aws_subnet" "public_subnets" {
  count             = length(var.public_subnet_3cidrs)
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = element(var.public_subnet_3cidrs, count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = {
    Name = "Public-Subnet ${count.index + 1}"
  }
}

# create resouce internet gateway 
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "main-VPC-IGW"
  }

}

# create a route table for IGW association
resource "aws_route_table" "igw_route_table" {
  vpc_id = aws_vpc.main_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "IGW-RouteTable"
  }
}
# create subnet association with IGW route table
resource "aws_route_table_association" "subnet_association" {
  count          = length(var.public_subnet_3cidrs)
  subnet_id      = element(aws_subnet.public_subnets[*].id, count.index)
  route_table_id = aws_route_table.igw_route_table.id
}

#create security group to allow http,ssh inbound and allow all outgoing
# resource "aws_security_group" "http_ssh_allow" {
#   name        = "http_ssh_allow_sg"
#   description = "allow inbound traffic from ALB"
#   vpc_id      = aws_vpc.main_vpc.id

#   # Allow http incoming
#   ingress {
#     from_port   = 80
#     to_port     = 80
#     protocol    = "tcp"
#     cidr_blocks = ["174.128.182.232/32"]
#   }
#   # Allow ssh incoming
#   ingress {
#     from_port   = 22
#     to_port     = 22
#     protocol    = "tcp"
#     cidr_blocks = ["174.128.182.232/32"]
#   }
#   # allow all out going - to access the internet
#   egress {
#     from_port   = "0"
#     to_port     = "0"
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = {
#     name = "http_ssh_allow_SG"
#   }
# }

resource "aws_security_group" "asg_instance_sg" {
  name        = "asg-instance-sg"
  description = "allow inbound traffic from ALB"
  vpc_id      = aws_vpc.main_vpc.id
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.load_balancer_asg.id]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.load_balancer_asg.id]
  }

}

resource "aws_security_group" "load_balancer_asg" {
  name   = "load-balancer-asg"
  vpc_id = aws_vpc.main_vpc.id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["174.128.182.232/32"]
  }
  # Allow ssh incoming
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["174.128.182.232/32"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

# Create autoscale configuration
resource "aws_launch_configuration" "asg-config" {
  name_prefix = "asg-launch-config"
  image_id        = "ami-0b5eea76982371e91"
  instance_type   = "t2.micro"
  user_data       = file("user-data.sh")
  #key_name = "aws_key_pair.localkeyname.key_name"
  security_groups = [aws_security_group.asg_instance_sg.id]
  lifecycle {
    create_before_destroy = true
  }
}
# Create autoscale group 
resource "aws_autoscaling_group" "autoscaling_group3" {
  name = "project-autoscaling"
  min_size             = 3
  max_size             = 5
  desired_capacity     = 3
  launch_configuration = aws_launch_configuration.asg-config.name #aws_launch_configuration.autoscaling_group3.name
  #vpc_zone_identifier  = [aws_vpc.main_vpc]
  vpc_zone_identifier = data.aws_availability_zones.available.group_names
  #module.vpc.public_subnets
  tag {
    key                 = "Name"
    value               = "Terraform - Autoscaling EC2"
    propagate_at_launch = true
  }
}
# create load balancer
resource "aws_lb" "load_balancer_asg" {
  name               = "asg-load-balancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.asg_instance_sg.name]
  subnets            = ["aws_vpc.main_vpc.public_subnets"]
  #module.vpc.public_subnets
}

resource "aws_lb_listener" "lb_listener" {
  load_balancer_arn = aws_lb.load_balancer_asg.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group_lb.arn
  }
}
resource "aws_lb_target_group" "target_group_lb" {
  name     = "target-group-lb"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main_vpc.id

  health_check {
    port     = 80
    protocol = "HTTP"
  }
}
resource "aws_autoscaling_attachment" "autoscaling_attachment" {
  autoscaling_group_name = aws_autoscaling_group.autoscaling_group3.name
  alb_target_group_arn   = aws_lb_target_group.target_group_lb.arn
}