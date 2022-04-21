# ------------------------------------------------------------#
# SQS
# ------------------------------------------------------------#
resource "aws_sqs_queue" "dead_letter_queue" {
  name                       = "${var.env}-${var.pj_prefix}-dlq"
  delay_seconds              = 0
  max_message_size           = 262144
  message_retention_seconds  = 1209600 # 14 days
  receive_wait_time_seconds  = 20
  visibility_timeout_seconds = 300
}

resource "aws_sqs_queue" "trigger_queue" {
  name                       = "${var.env}-${var.pj_prefix}-trigger-queue"
  delay_seconds              = 0
  max_message_size           = 262144
  message_retention_seconds  = 1209600 # 14 days
  receive_wait_time_seconds  = 20
  visibility_timeout_seconds = 300
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dead_letter_queue.arn
    maxReceiveCount     = 3 # attempt to retry 3 times
  })
}

# ------------------------------------------------------------#
# SQS Policy
# ------------------------------------------------------------#
resource "aws_sqs_queue_policy" "dead_letter_queue_policy" {
  queue_url = aws_sqs_queue.dead_letter_queue.id

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "${aws_sqs_queue.dead_letter_queue.id}",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::${var.aws_account_id}:root"
      },
      "Action": "SQS:*",
      "Resource": "${aws_sqs_queue.dead_letter_queue.arn}"
    }
  ]
}
POLICY
}

resource "aws_sqs_queue_policy" "trigger_queue_policy" {
  queue_url = aws_sqs_queue.trigger_queue.id

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "${aws_sqs_queue.trigger_queue.id}",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::${var.aws_account_id}:root"
      },
      "Action": "SQS:*",
      "Resource": "${aws_sqs_queue.trigger_queue.arn}"
    }
  ]
}
POLICY
}
