terraform {
	required_version = ">= 1.5.0"

	required_providers {
		aws = {
			source  = "hashicorp/aws"
			version = "~> 5.0"
		}
	}
}

provider "aws" {
	region = var.aws_region
}

variable "aws_region" {
	description = "AWS region where the EC2 instance is created."
	type        = string
	default     = "ap-south-1"
}

variable "instance_type" {
	description = "EC2 instance type."
	type        = string
	default     = "t3.micro"
}

variable "key_name" {
	description = "Existing EC2 key pair name. Leave null to create the instance without SSH key authentication."
	type        = string
	default     = null
}

data "aws_vpc" "default" {
	default = true
}

data "aws_subnets" "default" {
	filter {
		name   = "vpc-id"
		values = [data.aws_vpc.default.id]
	}
}

data "aws_ami" "amazon_linux" {
	most_recent = true
	owners      = ["918734735613"]

	filter {
		name   = "name"
		values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
	}

	filter {
		name   = "virtualization-type"
		values = ["hvm"]
	}
}

resource "aws_instance" "this" {
	ami                         = "resolve:ssm:/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
	instance_type               = var.instance_type
	key_name                    = var.key_name
	associate_public_ip_address = true

	tags = {
		Name        = "terraform-ec2"
		Environment = "dev"
	}
}

output "instance_id" {
	description = "Created EC2 instance ID."
	value       = aws_instance.this.id
}

output "public_ip" {
	description = "Public IPv4 address of the EC2 instance."
	value       = aws_instance.this.public_ip
}
