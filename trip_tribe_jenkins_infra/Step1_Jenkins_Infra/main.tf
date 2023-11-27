module "vpc" {
  source           = "./modules/vpc"
  region           = var.region
  environment      = var.environment
  vpc_cidr         = var.vpc_cidr
  desired_az_count = var.desired_az_count

}

# create a parameter store to store jenkins login password
resource "aws_ssm_parameter" "jenkins_passwd" {
  name        = "jenkins-pwd"
  description = "Setting Up Jenkins Login Password"
  type        = "SecureString"
  value       = var.password

  tags = {
    Name        = "${var.environment}-aws-ssm-parameter"
    Environment = "${var.environment}"
  }
}
