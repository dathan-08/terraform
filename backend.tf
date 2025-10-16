terraform {
  backend "s3" {
    bucket = "devadathan-s3-bucket"
    key    = "devadathan/terraform.tfstate"
    region = "us-east-1"
  }
}
