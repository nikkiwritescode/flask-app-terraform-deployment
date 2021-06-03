resource "aws_dynamodb_table" "flask-db-table-1" {
  name           = "${var.app_name}-${var.env_prefix}-FlaskDB"
  billing_mode   = "PROVISIONED"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "Name"
  range_key      = "Party"

  attribute {
    name = "Name"
    type = "S"
  }

  attribute {
    name = "Party"
    type = "S"
  }

  ttl {
    attribute_name = "TimeToExist"
    enabled        = false
  }

  tags = {
    Name        = "${var.app_name}-${var.env_prefix}-flask-db-table-1"
    Environment = "${var.env_prefix}"
  }
}