resource "aws_cloudfront_distribution" "app_distribution" {
  origin {
    domain_name = aws_lb.app_lb.dns_name
    origin_id   = "app-alb"
    custom_origin_config {
      http_port              = 80
      https_port             = 443  # Required even if not used
      origin_protocol_policy = "http-only"  # Set to HTTP only
      origin_ssl_protocols   = ["TLSv1.2"]  # Still required, let's keep it
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  default_cache_behavior {
    target_origin_id       = "app-alb"
    viewer_protocol_policy = "allow-all"  # Set to HTTP and HTTPS
    allowed_methods        = ["GET", "HEAD"]  # Adjusted allowed methods
    cached_methods         = ["GET", "HEAD"]

    cache_policy_id        = "658327ea-f89d-4fab-a63d-7e88639e58f6"  # Amazon's caching-optimized cache policy ID
    origin_request_policy_id = "6885a789-2217-4ade-b2e8-97286b08e9ef"  # Amazon's origin request policy ID (optional)

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    min_ttl     = 0
    default_ttl = 3600
    max_ttl     = 86400
  }

  price_class = "PriceClass_100"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = false
  }
}
