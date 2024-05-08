locals {
    env = "local"
}

module "front_application_react" {
  source = "terraform-aws-modules/s3-bucket/aws"

  version = "v4.1.2"

  bucket = module.label_front_application.id

  control_object_ownership = true
  object_ownership         = "ObjectWriter"
}


resource "aws_s3_bucket_policy" "this" {
  bucket = module.front_application_react.s3_bucket_id
  policy = data.aws_iam_policy_document.this.json
}

data "aws_iam_policy_document" "this" {
  statement {
    principals {
      type        = "AWS"
      identifiers = ["${module.cdn.cloudfront_origin_access_identity_iam_arns[0]}"]
    }

    actions = [
      "s3:GetObject",
    ]

    resources = [
      "${module.front_application_react.s3_bucket_arn}/*",
    ]
  }
}