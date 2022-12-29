# Terraform required provider block
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.45"
    }
  }
  required_version = ">= 1.2.1"
}

provider "aws" {
  region = "us-east-1"
}

# main VPC block
resource "aws_vpc" "main_vpc" {
  cidr_block = "10.10.0.0/16"

  tags = {
    Name = "main-VPC"
  }

}