data "aws_cloudfront_cache_policy" "managed_caching_optimized" {
  name = "Managed-CachingOptimized"
}

data "aws_cloudfront_cache_policy" "managed_caching_disabled" {
  name = "Managed-CachingDisabled"
}

data "aws_cloudfront_origin_request_policy" "managed_all_viewer_except_host_header" {
  name = "Managed-AllViewerExceptHostHeader"
}

resource "aws_cloudfront_distribution" "grafana_app_aws_ordeq_co" {
  aliases             = [var.app_domain]
  default_root_object = null
  enabled             = true
  http_version        = "http2"
  is_ipv6_enabled     = true
  price_class         = "PriceClass_All"

  origin {
    origin_id           = "backend"
    connection_attempts = 3
    connection_timeout  = 10
    // we don't set origin_path here, stage is determined via Host header
    // domain_name = trimprefix(aws_apigatewayv2_api.grafana.api_endpoint, "https://")
    domain_name = trimprefix(aws_apigatewayv2_api.grafana.api_endpoint, "https://")
    origin_path = "/${aws_apigatewayv2_stage.grafana_production.name}"
    custom_origin_config {
      http_port                = 80
      https_port               = 443
      origin_keepalive_timeout = 5
      origin_protocol_policy   = "https-only"
      origin_read_timeout      = 30
      origin_ssl_protocols     = ["TLSv1.2"]
    }
  }

  default_cache_behavior {
    allowed_methods          = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cache_policy_id          = data.aws_cloudfront_cache_policy.managed_caching_disabled.id
    cached_methods           = ["GET", "HEAD"]
    compress                 = true
    default_ttl              = 0
    max_ttl                  = 0
    min_ttl                  = 0
    origin_request_policy_id = data.aws_cloudfront_origin_request_policy.managed_all_viewer_except_host_header.id
    target_origin_id         = "backend"
    viewer_protocol_policy   = "allow-all"
  }

  ordered_cache_behavior {
    allowed_methods          = ["GET", "HEAD", "OPTIONS"]
    cache_policy_id          = data.aws_cloudfront_cache_policy.managed_caching_optimized.id
    cached_methods           = ["GET", "HEAD", "OPTIONS"]
    compress                 = true
    default_ttl              = 60 * 60 * 24
    max_ttl                  = 60 * 60 * 24 * 365
    min_ttl                  = 60
    origin_request_policy_id = data.aws_cloudfront_origin_request_policy.managed_all_viewer_except_host_header.id
    path_pattern             = "/public"
    target_origin_id         = "backend"
    viewer_protocol_policy   = "https-only"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = var.certificate_arn
    minimum_protocol_version = "TLSv1.2_2021"
    ssl_support_method       = "sni-only"
  }
}
