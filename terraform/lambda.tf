# 1. The Lambda Layer (The "Internal" Dependencies)
resource "aws_lambda_layer_version" "python_libs" {
  filename            = "../lambda/dist/layer.zip"
  layer_name          = "${var.project_name}-layer"
  compatible_runtimes = ["python3.12"]
  description         = "Pillow and Boto3 dependencies"

  # This ensures Terraform knows to update the layer if the zip changes
  source_code_hash = filebase64sha256("../lambda/dist/layer.zip")
}

# 2. The Lambda Function
resource "aws_lambda_function" "processor" {
  filename      = "../lambda/dist/function.zip"
  function_name = "${var.project_name}-handler"
  role          = aws_iam_role.lambda_exec_role.arn
  handler       = "handler.lambda_handler" # File is handler.py, function is lambda_handler

  runtime = "python3.12"
  timeout = 30 # Processing images can take time
  memory_size = 512 # Image processing is memory intensive

  layers = [aws_lambda_layer_version.python_libs.arn]

  # Environment Variables (Best Practice: No hardcoding inside Python!)
  environment {
    variables = {
      DEST_BUCKET = aws_s3_bucket.destination.id
    }
  }

  source_code_hash = filebase64sha256("../lambda/dist/function.zip")
}

# 3. The "Permissions Gate" (Allow S3 to call Lambda)
resource "aws_lambda_permission" "allow_s3" {
  statement_id  = "AllowExecutionFromS3"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.processor.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.source.arn
}