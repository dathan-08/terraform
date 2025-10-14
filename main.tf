provider "aws" {
  region = "us-east-1"
}

module "ec2_instance" {
  source= "./modules/ec2_instance"
  ami_value = "ami-0360c520857e3138f"
  instance_type = "t3.micro"
  subnet_id_value = "subnet-01f68b874605475e6"
}