resource "aws_dynamodb_table" "authors" {
  name             = "authors"
  hash_key         = "id"
  read_capacity    = 10
  write_capacity   = 10

  attribute {
    name = "id"
    type = "S"
  }

  attribute {
    name = "firstName"
    type = "S"
  }

  attribute {
    name = "lastName"
    type = "S"
  }
}

resource "aws_dynamodb_table" "courses" {
  name             = "courses"
  hash_key         = "id"
  read_capacity    = 10
  write_capacity   = 10

  attribute {
    name = "id"
    type = "S"
  }

  attribute {
    name = "courseName"
    type = "S"
  }

  attribute {
    name = "instructorId"
    type = "S"
  }
}
