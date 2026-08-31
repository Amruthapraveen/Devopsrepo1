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
	default     = "t2.micro"

	validation {
		condition     = !(startswith(var.instance_type, "t4g") || startswith(var.instance_type, "a1"))
		error_message = "Selected instance type appears to be ARM-only (t4g, a1). Choose an x86_64 instance type such as t3.micro for the selected AMI."
	}
}

variable "key_name" {
	description = "Existing EC2 key pair name. Leave empty to create the instance without SSH key authentication."
	type        = string
	default     = ""
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

# Use a widely-available Amazon Linux 2 AMI name pattern (x86_64) so the data lookup
# is less likely to fail across regions. If you specifically need Amazon Linux 2023,
# replace the name pattern with the appropriate regional AMI name.
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "example" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"

  tags = {
    Name = "HelloWorld"
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
