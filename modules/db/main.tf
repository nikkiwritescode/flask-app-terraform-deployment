resource "aws_dynamodb_table" "candidate-table" { #"flask-db-table-1" {
  name           = "Candidates" #"${var.app_name}-${var.env_prefix}-FlaskDB" i wanna use this name if i can pls
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "CandidateName"

  attribute {
    name = "CandidateName"
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