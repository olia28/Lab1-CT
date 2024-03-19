output "table_info" {
  value = {
    table_name    = aws_dynamodb_table.this.name
    hash_key      = aws_dynamodb_table.this.hash_key
    dynamodb_arn  = aws_dynamodb_table.this.arn
  }
}