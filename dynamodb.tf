resource "aws_dynamodb_table" "coffee_orders" {
  name         = var.table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "orderID"

  attribute {
    name = "orderID"
    type = "S"
  }

  tags = {
    Project = "fourallthedogs"
  }
}