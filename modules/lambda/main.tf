module "labels" {
  source  = "cloudposse/label/null"
  name    = var.name
  stage   = var.stage
}

data "archive_file" "get_all_authors" {
  type        = "zip"
  source_file = "modules/lambda/functions/get-all-authors/get-all-authors.js"
  output_path = "modules/lambda/functions/get-all-authors/get-all-authors.zip"
}

resource "aws_lambda_function" "get_all_authors" {
  filename      = data.archive_file.get_all_authors.output_path
  function_name = "get-all-authors-${module.labels.stage}-${module.labels.name}"
  role          = var.get_all_authors_arn
  handler       = "get-all-authors.handler"

  source_code_hash = data.archive_file.get_all_authors.output_base64sha256

  runtime = "nodejs16.x"
}