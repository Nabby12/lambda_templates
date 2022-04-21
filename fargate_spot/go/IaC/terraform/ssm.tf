resource "aws_ssm_parameter" "env" {
  name  = "/${var.pj_prefix}/${var.env}/ENV"
  type  = "SecureString"
  value = var.env
}

resource "aws_ssm_parameter" "aws_region" {
  name  = "/${var.pj_prefix}/${var.env}/AWS_REGION"
  type  = "SecureString"
  value = var.aws_region
}

resource "aws_ssm_parameter" "end_point" {
  name  = "/${var.pj_prefix}/${var.env}/END_POINT"
  type  = "SecureString"
  value = "https://sqs.${var.aws_region}.amazonaws.com/"
}

resource "aws_ssm_parameter" "from_sqs_url" {
  name  = "/${var.pj_prefix}/${var.env}/FROM_SQS_URL"
  type  = "SecureString"
  value = aws_sqs_queue.trigger_queue.id
}
