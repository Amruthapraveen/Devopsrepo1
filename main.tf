variable "ami_value" {
    description = "value for the ami"
}

variable "instance_type_value" {
    description = "value for instance_type"
}

variable "subnet_id_value" {
    description = "value for the subnet_id"
}

provider "aws" {
  region = "us-east-1"
}

module "ec2_instance" {
  source = "./modules/ec2_instance"
  ami_value = "ami-01a00762f46d584a1" # replace this
  instance_type_value = "t2.micro"
  subnet_id_value = "subnet-0011c47ae6be75de9". # replace this
}
