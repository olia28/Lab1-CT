output "table_name" {
    value = aws_dynamodb_table.this.name
}

output "hash_key" {
    value = aws_dynamodb_table.this.hash_key
}

output "dynamodb_arn" {
  value = aws_dynamodb_table.this.arn
}
