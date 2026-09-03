provider "aws" {
  region = "ap-south-1"
}

module "ec2_instance" {
  source = "./modules/ec2_instance"
  ami_value = "ami-01a00762f46d584a1" # replace this
  instance_type_value = "t2.micro"
  subnet_id_value = "subnet-0011c47ae6be75de9". # replace this
}
