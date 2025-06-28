resource "aws_s3_bucket" "aoiorio-bucket-lambda-artifacts" {
  bucket = "aoiorio-bucket-lambda-artifacts"
  tags = {
    Name        = "aoiorio-lambda-bucket"
    Environment = "Dev"
  }
}

# ロールを生成
resource "aws_iam_role" "lambda" {
  name = "iam_for_lambda"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Principal = {
          Service = "lambda.amazonaws.com"
        },
        Effect = "Allow",
        Sid    = ""
      }
    ]
  })
}

# GetAccountSettings の権限をインラインポリシーとして付与
resource "aws_iam_role_policy" "get_account_settings" {
  name = "GetAccountSettingsPermission"
  role = aws_iam_role.lambda.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = "lambda:GetAccountSettings"
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

# 初回のみ利用する空のLambdaのファイルを生成
data "archive_file" "initial_lambda_package" {
  type        = "zip"
  output_path = "${path.module}/.temp_files/lambda.zip"
  source {
    content  = "# empty"
    filename = "fuga.txt"
  }
}

# 生成した空のLambdaのファイルをS3にアップロード
resource "aws_s3_object" "lambda_file" {
  bucket = aws_s3_bucket.aoiorio-bucket-lambda-artifacts.id
  key    = "initial.zip"
  source = "${path.module}/.temp_files/lambda.zip"
}

# Lambda関数を生成
# ソースコードは空のLambdaのファイルのS3を参照
resource "aws_lambda_function" "hello_go_function" {
  function_name = "hello_go_function"
  role          = aws_iam_role.lambda.arn
  handler       = "main.handler"
  runtime       = "provided.al2023"
  timeout       = 120
  publish       = true
  s3_bucket     = aws_s3_bucket.aoiorio-bucket-lambda-artifacts.id
  s3_key        = aws_s3_object.lambda_file.id
}

# 外部からリクエストを飛ばすためのエンドポイント
resource "aws_lambda_function_url" "hello_go_function" {
  function_name      = aws_lambda_function.hello_go_function.function_name
  authorization_type = "NONE"
}
