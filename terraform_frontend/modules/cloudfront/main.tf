resource "aws_cloudfront_function" "url_rewriting_func" {
  name    = "url_rewriting_func2"
  runtime = "cloudfront-js-1.0"
  comment = "my function"
  publish = true
  code    = file("${path.module}/url_rewriting_func.js")
}

resource "aws_cloudfront_origin_access_control" "cloudfront_s3_oac" {
  name                              = "CloudFront S3 OAC"
  description                       = "Cloud Front S3 OAC"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "my_distrib" {

  origin {
    domain_name = var.s3_bucket_primary.bucket_regional_domain_name
    origin_id   = "s3Primary"

    origin_access_control_id = aws_cloudfront_origin_access_control.cloudfront_s3_oac.id

  }
  origin {
    domain_name = var.s3_bucket_secondary.bucket_regional_domain_name
    origin_id   = "s3Failover"

    origin_access_control_id = aws_cloudfront_origin_access_control.cloudfront_s3_oac.id

  }


  enabled             = true
  default_root_object = "index.html"
  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "distribution"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400


    function_association {
      event_type   = "viewer-request"
      function_arn = aws_cloudfront_function.url_rewriting_func.arn
    }




  }
  viewer_certificate {
    # cloudfront_default_certificate = true

    cloudfront_default_certificate = false
    minimum_protocol_version       = "TLSv1.2_2021"

    ssl_support_method  = "sni-only"
    acm_certificate_arn = var.acm_certificate_arn


  }
  restrictions {
    geo_restriction {
      restriction_type = "none"
      locations        = []
    }
  }


  origin_group {
    origin_id = "distribution"

    member {
      origin_id = "s3Primary"
    }
    member {
      origin_id = "s3Failover"
    }
    failover_criteria {
      status_codes = [403, 404, 500, 502, 503, 504]

    }
  }

}


