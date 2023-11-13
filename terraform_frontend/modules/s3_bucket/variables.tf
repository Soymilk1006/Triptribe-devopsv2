variable "secondary_region" {
  description = "apply a backup s3 bucket in a secondary region for failover"
  type        = string
  default     = "ap-southeast-1"

}

variable "s3_bucket_primary" {
  description = "main s3 bucket to store web frontend files"
  type        = string

}

variable "s3_bucket_secondary" {
  description = "secondary s3 bucket to store web frontend files in a different region for cloudfront origin failover"
  type        = string


}


variable "s3_bucket_logs" {
  description = "bucket to store main s3 bucket access log for future anlayse"
  type        = string


}


variable "aws_iam_role_name" {
  description = "create a role for s3 bucket replication"
  type        = string

}
