module "ses" {
  source  = "cloudposse/ses/aws"
  version = "0.24.0"

  domain        = var.domain
  zone_id       = aws_route53_zone.private_dns_zone.zone_id
  verify_dkim   = var.verify_dkim
  verify_domain = var.verify_domain
  iam_permissions = ["s3:PutObject"]
  iam_allowed_resources = ["${aws_s3_bucket.inbox_s3.arn}/*"]
  context = module.this.context
}

resource "aws_ses_receipt_rule_set" "rule_set" {
  rule_set_name = "receive-rule-set"
  
}

resource "aws_ses_active_receipt_rule_set" "rule_set_activation" {
  rule_set_name = "receive-rule-set"
}

resource "aws_ses_receipt_rule" "store" {
  name          = "store"
  rule_set_name = aws_ses_receipt_rule_set.rule_set.rule_set_name
  recipients    = ["ratemy@bbq.benoxley.com"]
  enabled       = true
  scan_enabled  = true

  add_header_action {
    header_name  = "Custom-Header"
    header_value = "Added by SES"
    position     = 1
  }

  s3_action {
    bucket_name = aws_s3_bucket.inbox_s3.bucket
    position    = 2
  }
  
}

resource "aws_s3_bucket" "inbox_s3" {
  bucket = "aws-bbq-inbox-dev-ireland"
 
  tags = {
    Name        = "AWS bbq inbox"
    Environment = "dev"
  }
}

resource "aws_s3_bucket_policy" "b" {
  bucket = aws_s3_bucket.inbox_s3.id

  policy = <<POLICY
{
  "Version":"2012-10-17",
  "Statement":[
    {
      "Sid":"AllowSESPuts",
      "Effect":"Allow",
      "Principal":{
        "Service":"ses.amazonaws.com"
      },
      "Action":"s3:PutObject",
      "Resource":"arn:aws:s3:::${aws_s3_bucket.inbox_s3.bucket}/*",
      "Condition":{
        "StringEquals":{
          "AWS:SourceAccount":"536507824931",
          "AWS:SourceArn": "arn:aws:ses:eu-west-1:536507824931:receipt-rule-set/receive-rule-set:receipt-rule/store"
        }
      }
    }
  ]
}
POLICY
}

