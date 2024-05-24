resource "aws_dynamodb_table" "canary-table" {
    name            = "canarytable"
    billing_mode    = "PROVISIONED"
    read_capacity   = 1
    write_capacity  = 1
    hash_key        = "minute"

    attribute {
        name    = "minute"
        type    = "S"
    }

    tags = {
        Name        = "Canary Dynamodb table"
        Environment = "Development"
    }
}
