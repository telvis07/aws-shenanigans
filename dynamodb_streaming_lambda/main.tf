terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "us-west-2"
}


# {"id":1,"year":2001,"make":"ACURA","model":"CL"}
resource "aws_dynamodb_table" "cars_dynamodb_table" {
  name         = "CarsDemo"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"
  range_key    = "make"

  stream_enabled   = true
  stream_view_type = "NEW_AND_OLD_IMAGES"

  attribute {
    name = "id"
    type = "S"
  }

  attribute {
    name = "make"
    type = "S"
  }

  global_secondary_index {
    name            = "make_id_inverted"
    hash_key        = "make"
    range_key       = "id"
    projection_type = "ALL"
  }

  tags = {
    Name        = "cars_demo_table"
    Environment = "technicalelvis"
  }

  replica {
    region_name = "us-east-2"
  }
}


# Lambda for dynnamodb stream
resource "aws_s3_bucket" "lambda_bucket" {
  bucket = "technicalelvis-cars-lambda"

  tags = {
    Name        = "ddb_stream_lamgda"
    Environment = "technicalelvis"
  }
}

resource "aws_s3_bucket_acl" "lambda_bucket_acl" {
  bucket = aws_s3_bucket.lambda_bucket.id
  acl    = "private"
}

data "archive_file" "lambda_cars_lambda" {
  type = "zip"

  source_file = "${path.module}/lambda_function.py"
  output_path = "${path.module}/cars_lambda.zip"
}

resource "aws_s3_object" "lambda_cars_lambda" {
  bucket = aws_s3_bucket.lambda_bucket.id

  key    = "cars_lambda.zip"
  source = data.archive_file.lambda_cars_lambda.output_path

  etag = filemd5(data.archive_file.lambda_cars_lambda.output_path)
}


resource "aws_lambda_function" "cars_lambda" {
  function_name = "CarsDemoLambda"

  s3_bucket = aws_s3_bucket.lambda_bucket.id
  s3_key    = aws_s3_object.lambda_cars_lambda.key

  runtime = "python3.8"
  handler = "lambda_function.lambda_handler"

  source_code_hash = data.archive_file.lambda_cars_lambda.output_base64sha256

  role = aws_iam_role.lambda_exec.arn
}

resource "aws_cloudwatch_log_group" "cars_lambda" {
  name = "/aws/lambda/${aws_lambda_function.cars_lambda.function_name}"

  retention_in_days = 30
}

resource "aws_iam_role" "lambda_exec" {
  name = "serverless_lambda"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}


resource "aws_iam_policy" "lambda_dynamo_stream_policy" {
  name = "lambda_dynamo_stream"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Effect" : "Allow",
        "Action" : "lambda:InvokeFunction",
        "Resource" : aws_lambda_function.cars_lambda.arn
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "dynamodb:DescribeStream",
          "dynamodb:GetRecords",
          "dynamodb:GetShardIterator",
          "dynamodb:ListStreams"
        ],
        "Resource" : aws_dynamodb_table.cars_dynamodb_table.stream_arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "cars_lambda_policy" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "dynamo_stream_lambda_policy_attachment" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = aws_iam_policy.lambda_dynamo_stream_policy.arn
}

resource "aws_lambda_event_source_mapping" "cars_lambda_source_mapping" {
  event_source_arn  = aws_dynamodb_table.cars_dynamodb_table.stream_arn
  function_name     = aws_lambda_function.cars_lambda.arn
  starting_position = "LATEST"
}
