# 1. Source Bucket (Where you upload images)
resource "aws_s3_bucket" "source" {
  bucket        = "${var.project_name}-source-${random_id.suffix.hex}"
  force_destroy = true # Allows terraform to delete bucket even if it has files
}

# 2. Destination Bucket (Where Lambda puts processed images)
resource "aws_s3_bucket" "destination" {
  bucket        = "${var.project_name}-dest-${random_id.suffix.hex}"
  force_destroy = true
}

# 3. Block Public Access (Zero Trust Step 1)
resource "aws_s3_bucket_public_access_block" "source_lockdown" {
  bucket = aws_s3_bucket.source.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_public_access_block" "dest_lockdown" {
  bucket = aws_s3_bucket.destination.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# 4. Zero Trust Bucket Policy (Enforce SSL & Identity)
resource "aws_s3_bucket_policy" "source_policy" {
  bucket = aws_s3_bucket.source.id
  policy = data.aws_iam_policy_document.allow_access_from_lambda.json
}

data "aws_iam_policy_document" "allow_access_from_lambda" {
  statement {
    sid    = "EnforceSSLOnly"
    effect = "Deny"
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    actions = ["s3:*"]
    resources = [
      aws_s3_bucket.source.arn,
      "${aws_s3_bucket.source.arn}/*"
    ]
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }

  statement {
    sid    = "LambdaAccessOnly"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = [aws_iam_role.lambda_exec_role.arn]
    }
    actions = [
      "s3:GetObject",
      "s3:ListBucket"
    ]
    resources = [
      aws_s3_bucket.source.arn,
      "${aws_s3_bucket.source.arn}/*"
    ]
  }
}

# Small helper to ensure bucket names are globally unique
resource "random_id" "suffix" {
  byte_length = 4
}