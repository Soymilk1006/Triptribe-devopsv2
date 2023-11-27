variable "state_bucket_name" {
  type = string
  # A random bucket name by default
  default = "tf-state-123456789012-ap-southeast-2"
}

variable "state_lock_table_name" {
  type    = string
  default = "tf-lock-table"
}
