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

	validation {
		condition     = !(startswith(var.instance_type, "t4g") || startswith(var.instance_type, "a1"))
		error_message = "Selected instance type appears to be ARM-only (t4g, a1). Choose an x86_64 instance type such as t3.micro for the selected AMI."
	}
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
	owners      = ["amazon"]

	filter {
		name   = "name"
		values = ["al2023-ami-*-x86_64"]
	}

	filter {
		name   = "virtualization-type"
		values = ["hvm"]
	}

	filter {
		name   = "architecture"
		values = ["x86_64"]
	}
}

resource "aws_instance" "this" {
	ami                         = data.aws_ami.amazon_linux.id
	instance_type               = var.instance_type
	subnet_id                   = data.aws_subnets.default.ids[0]
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
