provider "aws" {
    region = "us-east-1"
}

variable "instance_type" {
  description = "Instance_type"
  type = "string"
  default = "t3.micro"
}

resource "aws_instance" "example" {
  ami = "ami-0bbdd8c17ed981ef9"
  instance_type = var.instance_type
}