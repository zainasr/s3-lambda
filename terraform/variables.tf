variable "aws_region" {
  description = "Target region for AWS resources"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Prefix for all resources to ensure uniqueness"
  type        = string
  default     = "image-processor-zero-trust"
}