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

resource "aws_ssm_parameter" "sqs_end_point" {
  name  = "/${var.pj_prefix}/${var.env}/SQS_END_POINT"
  type  = "SecureString"
  value = "https://sqs.${var.aws_region}.amazonaws.com/"
}

resource "aws_ssm_parameter" "dead_letter_queue_url" {
  name  = "/${var.pj_prefix}/${var.env}/DEAD_LETTER_QUEUE_URL"
  type  = "SecureString"
  value = aws_sqs_queue.dead_letter_queue.id

  depends_on = [
    aws_sqs_queue.dead_letter_queue
  ]
}

resource "aws_ssm_parameter" "trigger_queue_url" {
  name  = "/${var.pj_prefix}/${var.env}/TRIGGER_QUEUE_URL"
  type  = "SecureString"
  value = aws_sqs_queue.trigger_queue.id

  depends_on = [
    aws_sqs_queue.trigger_queue
  ]
}
