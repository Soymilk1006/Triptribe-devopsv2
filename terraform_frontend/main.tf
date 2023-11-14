provider "aws" {
  region = var.default_region

}


module "s3_bucket" {
  source              = "./modules/s3_bucket"
  secondary_region    = var.secondary_region
  s3_bucket_primary   = var.s3_bucket_primary
  s3_bucket_secondary = var.s3_bucket_secondary
  s3_bucket_logs      = var.s3_bucket_logs
  aws_iam_role_name   = var.aws_iam_role_name

}



module "cloud-front" {
  source              = "./modules/cloudfront"
  acm_certificate_arn = var.acm_certificate_arn

  s3_bucket_primary   = module.s3_bucket.s3_bucket_primary
  s3_bucket_secondary = module.s3_bucket.s3_bucket_secondary
  depends_on          = [module.s3_bucket]

}



module "cdn-oac-bucket-policy-primary" {
  source           = "./modules/cdn-oac"
  bucket_id        = module.s3_bucket.s3_bucket_primary.id
  cloudfront_arn   = module.cloud-front.cloud_front_my_distrib.arn
  bucket_arn       = module.s3_bucket.s3_bucket_primary.arn
  default_region   = var.default_region
  secondary_region = null

}

module "cdn-oac-bucket-policy-failover" {
  source           = "./modules/cdn-oac"
  bucket_id        = module.s3_bucket.s3_bucket_secondary.id
  cloudfront_arn   = module.cloud-front.cloud_front_my_distrib.arn
  bucket_arn       = module.s3_bucket.s3_bucket_secondary.arn
  default_region   = var.default_region
  secondary_region = var.secondary_region

}


resource "aws_route53_record" "cloudfront" {
  name    = var.domain_name
  type    = "A"
  zone_id = var.route53_hosted_zone_id

  alias {
    name                   = module.cloud-front.cloud_front_my_distrib.domain_name
    zone_id                = module.cloud-front.cloud_front_my_distrib.hosted_zone_id
    evaluate_target_health = false
  }
}


