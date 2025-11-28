# main.tf

# ---------------------------------------------------------
# 1. CẤU HÌNH PROVIDER (Giữ nguyên)
# ---------------------------------------------------------
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    # Cần thêm provider archive để nén code lambda thành file zip
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# ---------------------------------------------------------
# 2. RESOURCE CŨ CỦA BẠN (Giữ nguyên)
# ---------------------------------------------------------
resource "aws_s3_bucket" "s3_bucket" {
  bucket = var.bucket_name

  tags = {
    Name        = var.project_name
    Environment = var.environment
  }
}

# ---------------------------------------------------------
# 3. YÊU CẦU MỚI: S3 BUCKET "linhclass-s3-bucket"
# ---------------------------------------------------------
resource "aws_s3_bucket" "linhclass_bucket" {
  bucket = "linhclass-s3-bucket" # Tên bucket cứng theo yêu cầu

  # Lưu ý: Tên S3 bucket phải là duy nhất trên toàn cầu (Global Unique).
  # Nếu tên này đã có người dùng rồi, bạn sẽ gặp lỗi khi apply.
  
  tags = {
    Name = "LinhClass Bucket"
  }
}

# ---------------------------------------------------------
# 4. YÊU CẦU MỚI: LAMBDA FUNCTION (NodeJS - console.log(123))
# ---------------------------------------------------------

# 4.1. Tạo IAM Role cho Lambda (Để Lambda có quyền chạy)
resource "aws_iam_role" "iam_for_lambda" {
  name = "linhclass_lambda_role"

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

# 4.2. Gán quyền ghi Log cho Lambda (Basic Execution Role)
resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# 4.3. Tạo file code zip (Dùng data source archive_file để tạo zip on-the-fly)
data "archive_file" "lambda_zip" {
  type        = "zip"
  output_path = "${path.module}/lambda_function.zip"
  
  source {
    content  = <<EOF
exports.handler = async (event) => {
    console.log(123);
    const response = {
        statusCode: 200,
        body: JSON.stringify('Hello from LinhClass Lambda!'),
    };
    return response;
};
EOF
    filename = "index.js"
  }
}

# 4.4. Tạo Lambda Function
resource "aws_lambda_function" "linhclass_lambda" {
  filename      = data.archive_file.lambda_zip.output_path
  function_name = "linhclass_function_node"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "index.handler"

  # Hash code để Terraform biết khi nào code thay đổi để update lại
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  runtime = "nodejs20.x" # Sử dụng Node.js phiên bản mới
}

# ---------------------------------------------------------
# 5. OUTPUTS
# ---------------------------------------------------------
output "bucket_name" {
  value       = aws_s3_bucket.my_first_bucket.id
  description = "Tên của S3 bucket ban đầu"
}

output "bucket_arn" {
  value       = aws_s3_bucket.my_first_bucket.arn
  description = "ARN của S3 bucket ban đầu"
}

output "new_bucket_name" {
  value       = aws_s3_bucket.linhclass_bucket.id
  description = "Tên bucket mới tạo thêm"
}

output "lambda_name" {
  value       = aws_lambda_function.linhclass_lambda.function_name
  description = "Tên của Lambda function"
}