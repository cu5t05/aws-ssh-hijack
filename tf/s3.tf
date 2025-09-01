resource "random_id" "bucket" {
  byte_length = 4
}

resource "aws_s3_bucket" "site" {
  bucket        = "${var.project_slug}-site-${random_id.bucket.hex}"
  force_destroy = true # destroy-safe for quick iteration
}

resource "aws_s3_bucket_ownership_controls" "site" {
  bucket = aws_s3_bucket.site.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_public_access_block" "site" {
  bucket                  = aws_s3_bucket.site.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

/*
Bucket policy is restricted to CloudFront via OAC.
It references the CloudFront Distribution ARN, so it will
apply after the distribution exists (Terraform handles ordering).
*/
data "aws_iam_policy_document" "site" {
  statement {
    sid     = "AllowCloudFrontServicePrincipalReadOnly"
    effect  = "Allow"
    actions = ["s3:GetObject", "s3:ListBucket"]

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    resources = [
      aws_s3_bucket.site.arn,
      "${aws_s3_bucket.site.arn}/*"
    ]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.site.arn]
    }
  }
}

resource "aws_s3_bucket_policy" "site" {
  bucket = aws_s3_bucket.site.id
  policy = data.aws_iam_policy_document.site.json
}
