output "source_bucket_name" {
  value = aws_s3_bucket.source.id
}

output "destination_bucket_name" {
  value = aws_s3_bucket.destination.id
}

output "lambda_function_arn" {
  value = aws_lambda_function.processor.arn
}