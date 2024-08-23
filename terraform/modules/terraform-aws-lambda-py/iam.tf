locals {
  exec_role_name = "${var.function_name}-exec-role"
}

resource "aws_iam_role" "exec_role" {
  name               = local.exec_role_name
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
  tags = merge(var.tags, {
    Name = local.exec_role_name
  })
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      identifiers = ["lambda.amazonaws.com"]
      type        = "Service"
    }
  }
}

resource "aws_iam_role_policy" "custom_policies" {
  for_each = var.custom_policies
  name     = each.key
  policy   = each.value
  role     = aws_iam_role.exec_role.name
}

resource "aws_iam_role_policy" "dynamodb_policy" {
  name   = "DynamoDBPolicy"
  role   = aws_iam_role.exec_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["dynamodb:GetItem", "dynamodb:Scan"],
        Effect   = "Allow",
        Resource = aws_dynamodb_table.text_table.arn
      }
    ]
  })
}