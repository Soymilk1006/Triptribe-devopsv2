terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.25.0"
    }
  }

  backend "s3" {
    bucket  = "myapp-bucket-linux"
    key     = "terraform.tfstate" # Optionally, set a different state file name
    region  = "ap-southeast-2"
    encrypt = true
    #dynamodb_table = "terraform_locks"    # Optionally, use DynamoDB for state locking
  }
}
