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