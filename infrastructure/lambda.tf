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
  timeout = 300

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
        }
      ]
    })
  }
}