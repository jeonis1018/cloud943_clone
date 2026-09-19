data "archive_file" "quarantine" {
  type        = "zip"
  source_file = var.lambda_source_path
  output_path = "${path.module}/quarantine_lambda.zip"
}

# ── IAM ──────────────────────────────────────────────────────────────────────

data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "quarantine_lambda" {
  name               = "quarantine-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

data "aws_iam_policy_document" "quarantine_ec2" {
  statement {
    actions = [
      "ec2:DescribeInstances",
      "ec2:ModifyNetworkInterfaceAttribute",
      "ec2:DescribeNetworkAcls",
      "ec2:ReplaceNetworkAclEntry",
      "ec2:CreateTags",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "quarantine_ec2" {
  name   = "quarantine-lambda-ec2"
  role   = aws_iam_role.quarantine_lambda.id
  policy = data.aws_iam_policy_document.quarantine_ec2.json
}

resource "aws_iam_role_policy_attachment" "basic_execution" {
  role       = aws_iam_role.quarantine_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# ── Lambda ────────────────────────────────────────────────────────────────────

resource "aws_lambda_function" "quarantine" {
  filename         = data.archive_file.quarantine.output_path
  source_code_hash = data.archive_file.quarantine.output_base64sha256
  function_name    = "quarantine-instance"
  role             = aws_iam_role.quarantine_lambda.arn
  handler          = "handler.handler"
  runtime          = "python3.12"
  timeout          = 30

  environment {
    variables = {
      QUARANTINE_SG_ID   = var.quarantine_sg_id
      NACL_ID            = var.nacl_id
      NACL_RULE_INBOUND  = tostring(var.nacl_rule_inbound)
      NACL_RULE_OUTBOUND = tostring(var.nacl_rule_outbound)
    }
  }
}
