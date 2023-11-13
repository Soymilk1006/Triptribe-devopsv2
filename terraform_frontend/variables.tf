variable "default_region" {
  description = "Default Region"
  type        = string
  default     = "ap-southeast-2"

}

variable "secondary_region" {
  description = "apply a backup s3 bucket in a secondary region for failover"
  type        = string
  default     = "ap-southeast-1"
}

variable "website_name" {
  description = "website name"
  type        = string
  default     = "www.tribe-trip.com"

}


variable "s3_bucket_primary" {
  description = "main s3 bucket to store web frontend files"
  type        = string
  default     = "www.tribe-trip.com-primary1234"
}

variable "s3_bucket_secondary" {
  description = "secondary s3 bucket to store web frontend files in a different region for cloudfront origin failover"
  type        = string
  default     = "www.tribe-trip.com-secondary1234"

}


variable "s3_bucket_logs" {
  description = "bucket to store main s3 bucket access log for future anlayse"
  type        = string
  default     = "www.tribe-trip.com-logs1234"

}

variable "acm_certificate_arn" {
  description = "custom ssl certifcate"
  type        = string
  default     = "arn:aws:acm:us-east-1:335441918609:certificate/ac1a2227-0938-449d-9f93-3cd301b4da7a"

}


variable "aws_iam_role_name" {
  description = "create a role for s3 bucket replication"
  type        = string
  default     = "tf-iam-role-bucket-replication2"

}
