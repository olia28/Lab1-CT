module "cdn" {
  source = "terraform-aws-modules/cloudfront/aws"
  version = "v3.4.0"

  comment = "My awesome CloudFront"
  enabled = true
  price_class = "PriceClass_100"
  retain_on_delete = false
  wait_for_deployment = false

  create_origin_access_identity = true
  origin_access_identities = {
    s3_bucket_one = "My awesome CloudFront can access"
  }

  origin = {

    s3_one = {
     domain_name = module.front_application_react.s3_bucket_bucket_domain_name
      s3_origin_config = {
        origin_access_identity = "s3_bucket_one"
      }
    }
  }

  default_cache_behavior = {
    target_origin_id           = "s3_one"
    viewer_protocol_policy     = "allow-all"

    allowed_methods = ["GET", "HEAD", "OPTIONS"]
    cached_methods  = ["GET", "HEAD"]
    compress        = true
    query_string    = true
  }
}