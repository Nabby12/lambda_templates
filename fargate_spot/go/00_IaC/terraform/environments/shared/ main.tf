terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.10.0"
    }
  }
  backend "s3" {
    # ${env}.tfbackendにて定義
    # terraform init -backend-config=${env}.tfbackend
  }
}

provider "aws" {
  region = var.aws_region
}

module "shared" {
  source = "../../modules/shared"

  pj_prefix = var.pj_prefix
}
