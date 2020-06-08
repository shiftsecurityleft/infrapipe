{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "DevUserBucket",
            "Effect": "Allow",
            "Action": "s3:*",
            "Resource": [
                ${S3_LIST}
            ]
        }
    ]
}