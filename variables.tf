# variables.tf

variable "aws_region" {
  description = "AWS region để deploy resources"
  type        = string
  default     = "ap-northeast-1"
}

variable "bucket_name" {
  description = "linhclass-test-terraform"
  type        = string
}

variable "environment" {
  description = "Environment tag (Dev, Staging, Production, Learning...)"
  type        = string
  default     = "Learning"
}

variable "project_name" {
  description = "Tên project"
  type        = string
  default     = "My First Terraform Bucket"
}
