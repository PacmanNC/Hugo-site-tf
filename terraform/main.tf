terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.57.1"
    }
  }
}

# AWS provider for resources
provider "aws" {
  alias  = "ap-southeast-1"
  region = var.s3_region
}

# AWS provider zone for SSL certificates
provider "aws" {
  alias  = "us-east-1"
  region = "us-east-1"
}

#S3 Origin ID used for Cloudfront Distribution
locals {
  # site_path     = "../mysite"
  default_certs = var.use_cloudfront_address ? ["default"] : []
  acm_certs     = var.use_cloudfront_address ? [] : ["acm"]
  alias_cloudfront_domain_names   = var.use_cloudfront_address ? [] : [var.website_domain_name, "www.${var.website_domain_name}"]
}

output "cloudfront_id" {
  value = aws_cloudfront_distribution.cloudfront.id
}

output "url" {
  value = aws_cloudfront_distribution.cloudfront.domain_name
}

