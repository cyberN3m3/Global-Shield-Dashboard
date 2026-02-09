# --- PRIMARY REGION (EAST) ---

resource "aws_s3_bucket" "primary" {
  bucket = "global-shield-primary-${var.unique_id}"
}

resource "aws_s3_bucket_website_configuration" "primary" {
  bucket = aws_s3_bucket.primary.id
  index_document { suffix = "index.html" }
}

resource "aws_s3_bucket_public_access_block" "primary" {
  bucket                  = aws_s3_bucket.primary.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "primary" {
  bucket = aws_s3_bucket.primary.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid       = "PublicReadGetObject"
      Effect    = "Allow"
      Principal = "*"
      Action    = "s3:GetObject"
      Resource  = "${aws_s3_bucket.primary.arn}/*"
    }]
  })
  depends_on = [aws_s3_bucket_public_access_block.primary]
}

# --- SECONDARY REGION (WEST) ---

resource "aws_s3_bucket" "secondary" {
  provider = aws.west
  bucket   = "global-shield-secondary-${var.unique_id}"
}

resource "aws_s3_bucket_website_configuration" "secondary" {
  provider = aws.west
  bucket   = aws_s3_bucket.secondary.id
  index_document { suffix = "index.html" }
}

resource "aws_s3_bucket_public_access_block" "secondary" {
  provider                = aws.west
  bucket                  = aws_s3_bucket.secondary.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "secondary" {
  provider = aws.west
  bucket   = aws_s3_bucket.secondary.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid       = "PublicReadGetObject"
      Effect    = "Allow"
      Principal = "*"
      Action    = "s3:GetObject"
      Resource  = "${aws_s3_bucket.secondary.arn}/*"
    }]
  })
  depends_on = [aws_s3_bucket_public_access_block.secondary]
}

# --- WATCHDOG ---

resource "aws_route53_health_check" "watchdog" {
  fqdn              = aws_s3_bucket.primary.bucket_regional_domain_name
  port              = 80
  type              = "HTTP"
  resource_path     = "/index.html"
  failure_threshold = "3"
  request_interval  = "30"
}

# --- CLOUDFRONT (GLOBAL) ---

resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name = aws_s3_bucket.primary.bucket_regional_domain_name
    origin_id   = "primaryS3"
  }

  origin {
    domain_name = aws_s3_bucket.secondary.bucket_regional_domain_name
    origin_id   = "secondaryS3"
  }

  origin_group {
    origin_id = "groupS3"
    failover_criteria {
      status_codes = [403, 404, 500, 502, 503, 504]
    }
    member { origin_id = "primaryS3" }
    member { origin_id = "secondaryS3" }
  }

  default_cache_behavior {
    target_origin_id       = "groupS3"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    
    # LIVE DEMO OPTIMIZATION: Disable caching so failover is visible immediately
    min_ttl                = 0
    default_ttl            = 0
    max_ttl                = 0

    forwarded_values {
      query_string = false
      cookies { forward = "none" }
    }
  }

  enabled             = true
  default_root_object = "index.html"

  restrictions {
    geo_restriction { restriction_type = "none" }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}
# Upload to Primary (East)
resource "aws_s3_object" "upload_primary" {
  bucket       = aws_s3_bucket.primary.id
  key          = "index.html"              # Name inside S3
  source       = "${path.module}/enhanced-dashboard.html" # Path to your local file
  content_type = "text/html"
}

# Upload to Secondary (West)
resource "aws_s3_object" "upload_secondary" {
  provider     = aws.west
  bucket       = aws_s3_bucket.secondary.id
  key          = "index.html"              # Name inside S3
  source       = "${path.module}/enhanced-failover-dashboard.html" # Path to your local file
  content_type = "text/html"
}
