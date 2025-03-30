resource "aws_s3_bucket" "my_terraform_bucket_indrajeet" {
  bucket = "my-tf-bucket-indrajit"

  tags = {
    Name        = "My bucket"
  }

}

# Enable S3 Bucket Versioning
resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.my_terraform_bucket_indrajeet.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Enable Default Encryption using AWS S3-managed keys (SSE-S3)
resource "aws_s3_bucket_server_side_encryption_configuration" "sse" {
  bucket = aws_s3_bucket.my_terraform_bucket_indrajeet.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_dynamodb_table" "terraform_locks" {
  name         = "terraform-lock-table"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  # Enable Encryption at Rest using AWS Managed KMS Key
  server_side_encryption {
    enabled = true
  }

  tags = {
    Name        = "TerraformLocks"
    Environment = "Dev"
  }
}