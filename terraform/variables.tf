variable "s3_region" {
  type        = string
  description = "s3 region"
  default     = "ap-southeast-1"
}

variable "website_domain_name" {
  type        = string
  description = "domain name"
  default     = ""
}

variable "website_domain_name_alternative" {
  description = "alternative domain name"
  default     = []
}

variable "website_bucket_name" {
  type        = string
  description = "name of s3 website bucket"
}

variable "use_cloudfront_address" {
  type        = bool
  description = "Use CloudFront address without Route53 and ACM"
}

variable "hosted_zone" {
  type        = string
  description = "Route53 hosted zone"
  default     = ""
}

variable "acm_certificate_domain" {
  description = "Domain of the ACM certificate"
  default     = null
}
