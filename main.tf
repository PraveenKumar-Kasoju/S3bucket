provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "my_bucket" {
  bucket = "my-bucket-kpc-test"
  acl    = "private"

  tags = {
    Name        = "MyBucket"
    Environment = "Dev"
  }
}
