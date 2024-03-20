module "labels" {
  source  = "cloudposse/label/null"
  name    = var.name
}

//get all authors
resource "aws_iam_policy" "get_all_authors_policy" {
  name        = "get_all_authors_policy" 
  policy      = data.aws_iam_policy_document.get-all-authors.json
}

data "aws_iam_policy_document" "get-all-authors" {
    statement {
      effect = "Allow"
      actions = [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "dynamodb:Scan"
      ]
      resources = [
        "*", 
        "${var.dynamodb_authors_arn}/*"
      ]
    }
}

resource "aws_iam_role" "get_all_authors_lambda_role" {
  name = "get-all-authors-lambda-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "sts:AssumeRole"
        ]
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_policy_to_lambda" {
  policy_arn = aws_iam_policy.get_all_authors_policy.arn
  role       = aws_iam_role.get_all_authors_lambda_role.name
}


//save course

resource "aws_iam_policy" "save_course_policy" {
  name        = "save_course_policy" 
  policy      = data.aws_iam_policy_document.save_course.json
}

resource "aws_iam_role" "save_course_lambda_role" {
  name = "save-course-lambda-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "sts:AssumeRole"
        ]
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_policy_to_lambda_save_course" {
  policy_arn = aws_iam_policy.save_course_policy.arn
  role       = aws_iam_role.save_course_lambda_role.name
}

data "aws_iam_policy_document" "save_course" {
    statement {
      effect = "Allow"
      actions = [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "dynamodb:PutItem",
        "dynamodb:Scan"
      ]
      resources = [
        "*", 
        "${var.dynamodb_courses_arn}/*"
      ]
    }
}

//update course

resource "aws_iam_role" "update_course_lambda_role" {
  name               = "update-course-lambda-role"
  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Action    = ["sts:AssumeRole"]
        Effect    = "Allow"
        Principal = { Service = "lambda.amazonaws.com" }
      }
    ]
  })
}

data "aws_iam_policy_document" "update_course" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "dynamodb:PutItem",
      "dynamodb:Scan"
    ]
    resources = [
      "*", 
      "${var.dynamodb_courses_arn}/*"
    ]
  }
}

resource "aws_iam_policy" "update_course_policy" {
  name   = "update_course_policy"
  policy = data.aws_iam_policy_document.update_course.json
}

resource "aws_iam_role_policy_attachment" "attach_policy_to_lambda_update_course" {
  policy_arn = aws_iam_policy.update_course_policy.arn
  role       = aws_iam_role.update_course_lambda_role.name
}

//get all courses

resource "aws_iam_role" "get_all_courses_lambda_role" {
  name               = "get-all-courses-lambda-role"
  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Action    = ["sts:AssumeRole"]
        Effect    = "Allow"
        Principal = { Service = "lambda.amazonaws.com" }
      }
    ]
  })
}

data "aws_iam_policy_document" "get_all_courses" {
  statement {
    effect    = "Allow"
    actions   = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "dynamodb:Scan",
      "dynamodb:GetItem",
    ]
    resources = ["*", "${var.dynamodb_courses_arn}/*"]
  }
}

resource "aws_iam_policy" "get_all_courses_policy" {
  name   = "get_all_courses_policy"
  policy = data.aws_iam_policy_document.get_all_courses.json
}

resource "aws_iam_role_policy_attachment" "attach_policy_to_lambda_get_all_courses" {
  policy_arn = aws_iam_policy.get_all_courses_policy.arn
  role       = aws_iam_role.get_all_courses_lambda_role.name
}

//get one course

resource "aws_iam_role" "get_one_course_lambda_role" {
  name               = "get-one-course-lambda-role"
  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Action    = ["sts:AssumeRole"]
        Effect    = "Allow"
        Principal = { Service = "lambda.amazonaws.com" }
      }
    ]
  })
}

data "aws_iam_policy_document" "get_one_course" {
  statement {
    effect    = "Allow"
    actions   = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "dynamodb:Scan",
      "dynamodb:GetItem",
    ]
    resources = ["*", "${var.dynamodb_courses_arn}/*"]
  }
}

resource "aws_iam_policy" "get_one_course_policy" {
  name   = "get_one_course_policy"
  policy = data.aws_iam_policy_document.get_one_course.json
}

resource "aws_iam_role_policy_attachment" "attach_policy_to_lambda_get_one_course" {
  policy_arn = aws_iam_policy.get_one_course_policy.arn
  role       = aws_iam_role.get_one_course_lambda_role.name
}

//delete course

resource "aws_iam_role" "delete_course_lambda_role" {
  name               = "delete-course-lambda-role"
  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Action    = ["sts:AssumeRole"]
        Effect    = "Allow"
        Principal = { Service = "lambda.amazonaws.com" }
      }
    ]
  })
}

data "aws_iam_policy_document" "delete_course" {
  statement {
    effect    = "Allow"
    actions   = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "dynamodb:Scan",
      "dynamodb:DeleteItem",
    ]
    resources = ["*", "${var.dynamodb_courses_arn}/*"]
  }
}

resource "aws_iam_policy" "delete_course_policy" {
  name   = "delete_course_policy"
  policy = data.aws_iam_policy_document.delete_course.json
}

resource "aws_iam_role_policy_attachment" "attach_policy_to_lambda_delete_course" {
  policy_arn = aws_iam_policy.delete_course_policy.arn
  role       = aws_iam_role.delete_course_lambda_role.name
}

