# Archive lambda function
data "archive_file" "main" {
  type        = "zip"
  source_dir  = "../src/mail-parse"
  output_path = "${path.module}/.terraform/archive_files/function.zip"

  depends_on = [null_resource.main]
}

# Provisioner to install dependencies in lambda package before upload it.
resource "null_resource" "main" {

  triggers = {
    updated_at = timestamp()
  }

  provisioner "local-exec" {
    command = "npm i"

    working_dir = "../src/mail-parse"
  }
}

resource "aws_lambda_function" "lambda_hello_world" {
  filename      = "${path.module}/.terraform/archive_files/function.zip"
  function_name = "lambda-mail-parse"
  role          = aws_iam_role.lambda_hello_world_role.arn
  handler       = "mail-parse.handler"
  runtime       = "nodejs16.x"
  timeout       = 300

  source_code_hash = data.archive_file.main.output_base64sha256
}

resource "aws_iam_role" "lambda_hello_world_role" {
  name               = "lambda_mail_parse_role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
  inline_policy {
    name = "lamda-mail-parse-policy"
    policy = jsonencode({
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Sid" : "LambdaMailParse",
          "Effect" : "Allow",
          "Action" : [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents",
          ],
          "Resource" : "*"
        },
        {
          "Sid" : "LambdaS3",
          "Effect" : "Allow",
          "Action" : [
            "s3:GetObject",
            "s3:PutObject"
          ],
          "Resource" : "*"
        },
        {
          "Sid" : "LambdaDynamo",
          "Effect" : "Allow",
          "Action" : [
            "dynamodb:PutItem"
          ],
          "Resource" : "*"
        },
        {
          "Sid" : "LambdaSendEmail",
          "Effect" : "Allow",
          "Action" : [
            "ses:SendEmail"
          ],
          "Resource" : "*"
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "rekognition:*"
          ],
          "Resource" : "*"
        },
        {
          "Sid" : "PassRole",
          "Effect" : "Allow",
          "Action" : "iam:PassRole",
          "Resource" : "*"
        }
      ]
    })
  }
}

resource "aws_s3_bucket_notification" "my-trigger" {
  bucket = aws_s3_bucket.inbox_s3.bucket

  lambda_function {
    lambda_function_arn = aws_lambda_function.lambda_hello_world.arn
    events              = ["s3:ObjectCreated:*"]
  }
}

resource "aws_lambda_permission" "test" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_hello_world.arn
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.inbox_s3.arn
}



resource "aws_s3_bucket" "images_s3" {
  bucket = "aws-bbq-images-dev-ireland"

  tags = {
    Name        = "AWS bbq images"
    Environment = "dev"
  }
}


resource "aws_s3_bucket_policy" "images_s3_rekognition" {
  bucket = aws_s3_bucket.images_s3.id

  policy = <<POLICY
{
  "Version":"2012-10-17",
  "Statement":[
    {
      "Sid":"AllowRekognitionGet",
      "Effect":"Allow",
      "Principal":{
        "Service":"lambda.amazonaws.com"
      },
      "Action":"s3:GetObject",
      "Resource":"arn:aws:s3:::${aws_s3_bucket.images_s3.bucket}/*",
      "Condition":{
        "StringEquals":{
          "AWS:SourceAccount":"536507824931"
        }
      }
    }
  ]
}
POLICY
}

