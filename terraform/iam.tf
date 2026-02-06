# 1. The Execution Role (The Identity)
resource "aws_iam_role" "lambda_exec_role" {
  name = "${var.project_name}-lambda-role"

  # Trust Policy: Allows Lambda service to "assume" this role
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

# 2. Permissions Policy (The specific rights)
resource "aws_iam_policy" "lambda_logging_s3_policy" {
  name        = "${var.project_name}-combined-policy"
  description = "Allow Lambda to write logs and access specific S3 buckets"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # CloudWatch Logs (Essential for debugging)
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Effect   = "Allow"
        Resource = "arn:aws:logs:*:*:*"
      },
      # Source Bucket: Read Only
      {
        Action   = ["s3:GetObject"]
        Effect   = "Allow"
        Resource = "${aws_s3_bucket.source.arn}/*"
      },
      # Destination Bucket: Write Only
      {
        Action   = ["s3:PutObject"]
        Effect   = "Allow"
        Resource = "${aws_s3_bucket.destination.arn}/*"
      }
    ]
  })
}

# 3. Attach the Policy to the Role
resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = aws_iam_policy.lambda_logging_s3_policy.arn
}