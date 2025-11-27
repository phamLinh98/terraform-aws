# main.tf

# Cấu hình AWS provider
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Tạo S3 bucket
resource "aws_s3_bucket" "my_first_bucket" {
  bucket = var.bucket_name
  
  tags = {
    Name        = var.project_name
    Environment = var.environment
  }
}

# Output để xem thông tin bucket sau khi tạo
output "bucket_name" {
  value       = aws_s3_bucket.my_first_bucket.id
  description = "Tên của S3 bucket"
}

output "bucket_arn" {
  value       = aws_s3_bucket.my_first_bucket.arn
  description = "ARN của S3 bucket"
}