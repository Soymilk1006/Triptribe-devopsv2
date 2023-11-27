variable "environment" {
  description = "Deployment Jenkins Infra Environment"
  default     = "jenkins_infra"
}

variable "desired_az_count" {
  description = "apply to number of availability zone "
  default     = 2
}


variable "vpc_cidr" {
  description = "CIDR block of the vpc"
  default     = "172.30.0.0/16"
}


variable "region" {
  description = "Region in which the bastion host will be launched"
  type        = string
  default     = "ap-southeast-2"

}

