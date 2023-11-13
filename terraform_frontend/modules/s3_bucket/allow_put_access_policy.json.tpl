{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "logging.s3.amazonaws.com"
      },
      "Action": "s3:PutObject",
      "Resource": "${bucket_name}/s3-logs/*",
      "Condition": {
        "StringEquals": {
          "aws:SourceAccount": "${aws_account_id}"
        },
        "ArnLike": {
          "aws:SourceAccount": "${s3_primary_bucket_name}"
        }
      }
    },
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "logging.s3.amazonaws.com"
      },
      "Action": "s3:PutObject",
      "Resource": "${bucket_name}/*"
    }
  ]
}
