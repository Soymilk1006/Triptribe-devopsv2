# Jenkins VPC Infrastructure Setup

## Step 1: Terraform S3 Backend with DynamoDB Lock

To ensure proper state management and prevent concurrent executions, follow these steps to set up the Terraform S3 backend with a DynamoDB lock.

### Create DynamoDB Table

Run the following AWS CLI command to create a DynamoDB table named `terraform-lock`:

```bash
aws dynamodb create-table \
    --region ap-southeast-2 \
    --table-name terraform-lock \
    --attribute-definitions AttributeName=LockID,AttributeType=S \
    --key-schema AttributeName=LockID,KeyType=HASH \
    --provisioned-throughput ReadCapacityUnits=1,WriteCapacityUnits=1
```

## Step 2: Modify the S3 Bucket Configuration

Update the `provider.tf` file to match your own S3 bucket and key name. This ensures that Terraform uses the correct storage location for managing state.

## Step 3: Create Parameter Store for Jenkins Default Login Password

Create an AWS Systems Manager (SSM) Parameter Store entry named `jenkins-pwd` to store the default login password for Jenkins. Note that the name `jenkins-pwd` is essential and cannot be changed, as Jenkins will specifically request the password from the parameter store based on this name during its creation.

## Step 4: Terraform Initialization and Deployment

Follow these Terraform commands to initialize, format, validate, plan, and apply your infrastructure changes.

```bash
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply

```

During the terraform apply step, you will be prompted to input the default `Jenkins login password`. Provide your desired password, for example:

Input your own jenkins-pwd: `triptribe-jr11`

This password will be retrieved from the AWS Systems Manager Parameter Store during the Jenkins creation process.
