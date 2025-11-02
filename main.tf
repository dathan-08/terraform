provider "aws" {
  region = "us-east-1"
}

module "ec2_instance" {
  source= "./modules/ec2_instance"
  ami_value = "ami-0ecb62995f68bb549"
  instance_type = "m7i-flex.large"
  subnet_id_value = "subnet-06083ff91e1b2459c"
}

module "s3_bucket" {
  source= "./modules/s3_bucket"
  bucket_name = "devadathan-s3-bucket"
}

