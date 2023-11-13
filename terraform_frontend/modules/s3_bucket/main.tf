# Best Practise is that export creditials to enviroment variables
# Best Practise is to configure ~/.aws/credentials file,which can do through aws configure command 
# export AWS_ACCESS_KEY_ID=your_access_key_id
# export AWS_SECRET_ACCESS_KEY=your_secret_access_key



#query aws account ID
data "aws_caller_identity" "current" {}

#generate a random suffix to create 1 unique s3 bucket name
/*

provider "random" {}

resource "random_string" "bucket_suffix" {
  length  = 8
  special = false
}

*/



resource "aws_s3_bucket" "s3_bucket_primary" {
  bucket        = var.s3_bucket_primary
  force_destroy = true
}



# enable versioning
resource "aws_s3_bucket_versioning" "s3_bucket_primary_versioning_enabled" {
  bucket = aws_s3_bucket.s3_bucket_primary.id
  versioning_configuration {
    status = "Enabled"
  }
}


#enable Cross-origin resource sharing (CORS)
resource "aws_s3_bucket_cors_configuration" "website_cors_rules" {
  bucket = aws_s3_bucket.s3_bucket_primary.id

  cors_rule {
    allowed_methods = ["GET"]
    allowed_origins = ["*"]
    allowed_headers = ["*"]
  }
}

# enable Sever access logging on the 's3_bucket_primary'
resource "aws_s3_bucket_logging" "server_access_logging_enabled" {
  depends_on = [aws_s3_bucket.s3_bucket_logs, aws_s3_object.s3_logs_file]
  bucket     = aws_s3_bucket.s3_bucket_primary.id

  target_bucket = aws_s3_bucket.s3_bucket_logs.id
  target_prefix = "s3-logs/"
}





/*******************************************************************************

#set up bucket policy

resource "aws_s3_bucket_policy" "allow_access_from_everywhere" {
  depends_on = [data.aws_iam_policy_document.allow_access_from_everywhere]
  bucket     = aws_s3_bucket.s3_bucket_primary.id
  policy     = data.aws_iam_policy_document.allow_access_from_everywhere.json
}


data "aws_iam_policy_document" "allow_access_from_everywhere" {
  statement {
    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions = [
      "s3:GetObject"
    ]

    resources = [

      "${aws_s3_bucket.s3_bucket_primary.arn}/*"
    ]
  }
}


# set up Public access on the primary s3 public access
resource "aws_s3_bucket_public_access_block" "s3_bucket_public_access_block" {
  bucket = aws_s3_bucket.s3_bucket_primary.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# set the primary s3 bucket's ownership control
resource "aws_s3_bucket_ownership_controls" "ownership_controls" {
  bucket = aws_s3_bucket.s3_bucket_primary.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}


# set up ACL on the primary s3 public access to public-read
resource "aws_s3_bucket_acl" "example" {
  depends_on = [
    aws_s3_bucket_ownership_controls.ownership_controls,
    aws_s3_bucket_public_access_block.s3_bucket_public_access_block,
  ]

  bucket = aws_s3_bucket.s3_bucket_primary.id
  acl    = "public-read"
}

*************************************************************************/



/*** create a 's3_bucket_logs' bucket to store access logs from 's3_bucket_primary' bucket ***/

resource "aws_s3_bucket" "s3_bucket_logs" {
  bucket        = var.s3_bucket_logs
  force_destroy = true
}

#enable versioning
resource "aws_s3_bucket_versioning" "s3_bucket_logs_versioning_enabled" {
  bucket = aws_s3_bucket.s3_bucket_logs.id
  versioning_configuration {
    status = "Enabled"
  }
}

#set up bucket policy allowing put access from 's3_bucket_primary' bucket

resource "aws_s3_bucket_policy" "allow_put_access" {
  bucket = aws_s3_bucket.s3_bucket_logs.id
  policy = data.template_file.aws_s3_put_access_bucket_policy.rendered
}


data "template_file" "aws_s3_put_access_bucket_policy" {
  template = file("${path.module}/allow_put_access_policy.json.tpl")

  vars = {
    bucket_name            = "${aws_s3_bucket.s3_bucket_logs.arn}"
    s3_primary_bucket_name = "${aws_s3_bucket.s3_bucket_primary.arn}"
    aws_account_id         = "${data.aws_caller_identity.current.account_id}"
  }
}


# create a s3-logs file in "s3_bucket_logs"
resource "aws_s3_object" "s3_logs_file" {
  bucket = aws_s3_bucket.s3_bucket_logs.id
  key    = "s3-logs/"

}



/* Create a backup bucket in different region by using replication configuration*/

provider "aws" {
  alias  = "secondary_region"
  region = var.secondary_region
}

resource "aws_s3_bucket" "s3_bucket_secondary" {
  provider      = aws.secondary_region
  bucket        = var.s3_bucket_secondary
  force_destroy = true
}



# enable versioning
resource "aws_s3_bucket_versioning" "s3_bucket_secondary_versioning_enabled" {
  provider = aws.secondary_region
  bucket   = aws_s3_bucket.s3_bucket_secondary.id
  versioning_configuration {
    status = "Enabled"
  }
}


#enable Cross-origin resource sharing (CORS)
resource "aws_s3_bucket_cors_configuration" "website_cors_rules2" {
  provider = aws.secondary_region
  bucket   = aws_s3_bucket.s3_bucket_secondary.id

  cors_rule {
    allowed_methods = ["GET"]
    allowed_origins = ["*"]
    allowed_headers = ["*"]
  }
}



/*********************************************/




data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "replication" {
  name               = var.aws_iam_role_name
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "aws_iam_policy_document" "replication" {
  statement {
    effect = "Allow"

    actions = [
      "s3:GetReplicationConfiguration",
      "s3:ListBucket",
    ]

    resources = [aws_s3_bucket.s3_bucket_primary.arn]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:GetObjectVersionForReplication",
      "s3:GetObjectVersionAcl",
      "s3:GetObjectVersionTagging",
    ]

    resources = ["${aws_s3_bucket.s3_bucket_primary.arn}/*"]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:ReplicateObject",
      "s3:ReplicateDelete",
      "s3:ReplicateTags",
    ]

    resources = ["${aws_s3_bucket.s3_bucket_secondary.arn}/*"]
  }
}

resource "aws_iam_policy" "replication" {
  name   = var.aws_iam_role_name
  policy = data.aws_iam_policy_document.replication.json
}

resource "aws_iam_role_policy_attachment" "replication" {
  role       = aws_iam_role.replication.name
  policy_arn = aws_iam_policy.replication.arn
}



resource "aws_s3_bucket_replication_configuration" "replication" {
  # Must have bucket versioning enabled first
  depends_on = [aws_s3_bucket_versioning.s3_bucket_primary_versioning_enabled, aws_s3_bucket_versioning.s3_bucket_secondary_versioning_enabled]

  role   = aws_iam_role.replication.arn
  bucket = aws_s3_bucket.s3_bucket_primary.id

  rule {
    id       = "rule-id"
    priority = 1
    status   = "Enabled"

    destination {
      bucket        = aws_s3_bucket.s3_bucket_secondary.arn
      storage_class = "STANDARD"
    }
  }
}

