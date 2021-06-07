resource "aws_dynamodb_table" "candidate-table" { #"flask-db-table-1" {
  name           = "Candidates"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "CandidateName"

  attribute {
    name = "CandidateName"
    type = "S"
  }

  tags = {
    Name        = "${var.app_name}-${var.env_prefix}-flask-db-table-1"
    Environment = "${var.env_prefix}"
  }
}