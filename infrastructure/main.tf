provider "aws" {
  region = var.region
  profile = "main"
}

provider "awsutils" {
  region = var.region
  profile = "main"
}

module "vpc" {
  source  = "cloudposse/vpc/aws"
  name = "${var.namespace}-${var.stage}-${var.name}"
  ipv4_primary_cidr_block = "172.16.0.0/16"
  context = module.this.context
}

resource "aws_route53_zone" "private_dns_zone" {
  name = var.domain
  vpc {
    vpc_id = module.vpc.vpc_id
  }
  tags = module.this.tags
}

