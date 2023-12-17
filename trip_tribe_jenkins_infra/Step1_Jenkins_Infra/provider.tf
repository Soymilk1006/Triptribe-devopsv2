terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.25.0"
    }
  }

  backend "s3" {
    bucket         = "trip-tribe-infra"
    key            = "jenkins_infra/vpc_infra_jenkins.tfstate" # Optionally, set a different state file name
    region         = "ap-southeast-2"
    encrypt        = true
    dynamodb_table = "terraform-lock" # Optionally, use DynamoDB for state locking
  }
}
