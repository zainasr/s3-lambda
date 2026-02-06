resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.source.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.processor.arn
    events              = ["s3:ObjectCreated:*"]
    # filter_suffix       = ".jpg" # Optional: only trigger for images
  }

  # This depends_on is a "hidden" best practice. 
  # It ensures the permission is granted BEFORE S3 tries to set up the trigger.
  depends_on = [aws_lambda_permission.allow_s3]
}