# S3 Static Website
resource "aws_s3_bucket" "website_bucket" {
  provider      = aws.ap-southeast-1
  bucket        = var.website_bucket_name
  force_destroy = true
}

# resource "aws_s3_bucket_acl" "s3_bucket" {
#   bucket = var.website_bucket_name
#   acl    = "private"
# }

# resource "aws_s3_bucket_object" "content" {
#   for_each = fileset(local.site_path, "*")
#   bucket   = aws_s3_bucket.website_bucket.id
#   key      = each.value
#   source   = "${local.site_path}/${each.value}"
#   # etag     = filemd5("${local.site_path}/${each.value}")
# }

# resource "aws_s3_bucket_website_configuration" "website_bucket_configure" {
#   bucket = aws_s3_bucket.website_bucket.id

#   index_document {
#     suffix = "index.html"
#   }
# }

resource "aws_s3_bucket_public_access_block" "website_bucket_access" {
  bucket = aws_s3_bucket.website_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "allow_s3_cloudfront_traffic_policy" {
  bucket = aws_s3_bucket.website_bucket.id

  policy = jsonencode({
    "Version" : "2008-10-17",
    "Id" : "PolicyForCloudFrontPrivateContent",
    "Statement" : [
      {
        "Sid" : "AllowCloudFrontServicePrincipal",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "cloudfront.amazonaws.com"
        },
        "Action" : "s3:GetObject",
        "Resource" : "arn:aws:s3:::${var.website_bucket_name}/*",
        "Condition" : {
          "StringEquals" : {
            "AWS:SourceArn" : "${aws_cloudfront_distribution.cloudfront.arn}"
          }
        }
      },
      # {
      #   "Sid" : "PublicReadGetObject",
      #   "Effect" : "Allow",
      #   "Principal" : "*",
      #   "Action" : "s3:GetObject",
      #   "Resource" : "arn:aws:s3:::${var.website_bucket_name}/*"
      # }
    ]
  })
}