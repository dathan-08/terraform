variable "instance_type" {
  description = "Instance_type"
  type = string
  default = "t3.micro"
}

variable "ami_value" {
  description = "Ami_value"
  type = string
  default = "ami-0bbdd8c17ed981ef9"
}

variable "subnet_id_value" {
  description = "The ID of the subnet to launch the instance in"
  type = string
  default = "subnet-0bbdd8c17ed981ef9"
}