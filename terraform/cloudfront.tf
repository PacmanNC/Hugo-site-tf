# ACM SSL Certificates
data "aws_acm_certificate" "acm_cert" {
  count    = var.use_cloudfront_address ? 0 : 1
  domain   = coalesce(var.acm_certificate_domain, "${var.website_domain_name}")
  provider = aws.us-east-1
  statuses = [
    "ISSUED",
  ]
}

# CloudFront
resource "aws_cloudfront_distribution" "cloudfront" {
  depends_on = [
    aws_s3_bucket.website_bucket
  ]

  origin {
    domain_name              = aws_s3_bucket.website_bucket.bucket_regional_domain_name
    origin_id                = aws_s3_bucket.website_bucket.bucket_regional_domain_name # local.s3_origin_id
    origin_access_control_id = aws_cloudfront_origin_access_control.cloudfront_s3_origin_access_control.id
  }

  # origin {
  #   domain_name = aws_s3_bucket.website_bucket.bucket_regional_domain_name
  #   origin_id   = aws_s3_bucket.website_bucket.bucket_regional_domain_name
  #   s3_origin_config {
  #     origin_access_identity = aws_cloudfront_origin_access_identity.cloudfront_s3_origin_access_identity.cloudfront_access_identity_path
  #   }
  # }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  aliases = local.alias_cloudfront_domain_names

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = aws_s3_bucket.website_bucket.bucket_regional_domain_name # local.s3_origin_id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  dynamic "viewer_certificate" {
    for_each = local.default_certs
    content {
      cloudfront_default_certificate = true
    }
  }

  dynamic "viewer_certificate" {
    for_each = local.acm_certs
    content {
      acm_certificate_arn      = data.aws_acm_certificate.acm_cert[0].arn
      # acm_certificate_arn      = aws_acm_certificate.acm_cert[0].arn
      ssl_support_method       = "sni-only"
      minimum_protocol_version = "TLSv1"
    }
  }

  # custom_error_response {
  #   error_code            = 403
  #   response_code         = 200
  #   error_caching_min_ttl = 0
  #   response_page_path    = "/index.html"
  # }

  # wait_for_deployment = false
}

resource "aws_cloudfront_origin_access_control" "cloudfront_s3_origin_access_control" {
  name                              = aws_s3_bucket.website_bucket.bucket_regional_domain_name
  description                       = "private s3 bucket access"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_origin_access_identity" "cloudfront_s3_origin_access_identity" {
  comment = "site bucket origin"
}
