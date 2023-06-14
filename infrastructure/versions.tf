terraform {
  backend "s3" {
    bucket = "aws-bbq-state-dev-ireland"
    key    = "prod/terraform.tfstate"
    region = "eu-west-1"
    profile = "main"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
    }
    awsutils = {
      source  = "cloudposse/awsutils"
    }
    null = {
      source  = "hashicorp/null"
    }
  }
}

resource "aws_s3_bucket" "state" {
  bucket = "aws-bbq-state-dev-ireland"

  tags = {
    Name        = "AWS MQTT Dev Terraform State"
    Environment = "dev"
  }
}