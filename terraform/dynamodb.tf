resource "aws_dynamodb_table" "text_table" {
  name         = "TextTable"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }
}