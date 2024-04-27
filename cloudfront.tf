resource "aws_cloudfront_cache_policy" "this" {
  name = "${local.app}-cache-policy"
  parameters_in_cache_key_and_forwarded_to_origin {
    cookies_config {
      cookie_behavior = "all"
    }
    headers_config {
      header_behavior = "whitelist"
      headers {
        items = ["Content-Type", "Origin", "Accept"]
      }
    }
    query_strings_config {
      query_string_behavior = "all"
    }
  }
  default_ttl = 0
  min_ttl     = 0
  max_ttl     = 1
}

resource "aws_cloudfront_distribution" "this" {
  comment         = "${local.app} CloudFront Distribution"
  enabled         = true
  is_ipv6_enabled = true

  origin {
    domain_name = "${aws_api_gateway_rest_api.this.id}.execute-api.${local.region}.amazonaws.com"
    origin_id   = aws_api_gateway_rest_api.this.id
    origin_path = "/${aws_api_gateway_stage.dev.stage_name}"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  default_cache_behavior {
    allowed_methods        = ["GET", "POST", "PATCH", "PUT", "DELETE", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = aws_api_gateway_rest_api.this.id
    cache_policy_id        = aws_cloudfront_cache_policy.this.id
    viewer_protocol_policy = "redirect-to-https"
  }

  viewer_certificate {
    cloudfront_default_certificate = false
    acm_certificate_arn            = aws_acm_certificate.this.arn
    minimum_protocol_version       = "TLSv1.2_2021"
    ssl_support_method             = "sni-only"
  }

  aliases = [local.domain_name]
}

output "cloudfront_distribution_domain_name" {
  value = aws_cloudfront_distribution.this.domain_name
}

output "cloudfront_distribution_hosted_zone_id" {
  value = aws_cloudfront_distribution.this.hosted_zone_id
}
