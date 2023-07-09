# S3 bucket for website.
resource "aws_s3_bucket" "www_bucket" {
  bucket = var.domain

  cors_rule {
    allowed_headers = ["Authorization", "Content-Length"]
    allowed_methods = ["GET", "POST"]
    allowed_origins = ["https://${var.domain}"]
    max_age_seconds = 3000
  }

  website {
    index_document = "index.html"
    error_document = "404.html"
  }

  

}

resource "aws_s3_bucket_public_access_block" "www_bucket" {
  bucket = aws_s3_bucket.www_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}


resource "aws_s3_bucket_policy" "public_access" {
  bucket = aws_s3_bucket.www_bucket.id

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "PublicReadGetObject",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::${aws_s3_bucket.www_bucket.bucket}/*"
    }
  ]
}
POLICY
}

resource "aws_s3_bucket_website_configuration" "website-config" {
  bucket = aws_s3_bucket.www_bucket.bucket
  index_document {
    suffix = "index.html"
  }
  error_document {
    key = "404.jpeg"
  }
#   # IF you want to use the routing rule
#   routing_rule {
#     condition {
#       key_prefix_equals = "/abc"
#     }
#     redirect {
#       replace_key_prefix_with = "comming-soon.jpeg"
#     }
#   }
}

locals {
  mime_types = jsondecode(file("data/mime.json"))
}

resource "aws_s3_object" "object-upload" {
    for_each        = fileset("../src/bbq-ui/build", "**")
    bucket          = aws_s3_bucket.www_bucket.bucket
    key             = each.value
    source          = "../src/bbq-ui/build/${each.value}"
    content_type    = lookup(local.mime_types, regex("\\.[^.]+$", each.value), null)
    etag            = filemd5("../src/bbq-ui/build/${each.value}")
    acl = "public-read"
}
