# ------------------------------------------------------------#
# SecurityGroup
# ------------------------------------------------------------#
resource "aws_security_group" "container_sg" {
  name        = "${var.env}-${var.pj_prefix}-container-sg"
  description = "Security group for identification."
  vpc_id      = var.vpc_id

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "${var.env}-${var.pj_prefix}-container-sg"
  }
}

# ------------------------------------------------------------#
# IAMRole
# ------------------------------------------------------------#
resource "aws_iam_role" "ecs_task_role" {
  name = "${var.env}-${var.pj_prefix}-ecs-task-role"
  path = "/"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "sts:AssumeRole"
        Sid    = ""
        Principal = {
          Service = [
            "ecs-tasks.amazonaws.com",
            "events.amazonaws.com"
          ]
        }
      },
    ]
  })

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceEventsRole"
  ]

  inline_policy {
    name = "AllowSecretsAccess"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Action = [
            "sts:AssumeRole",
            "ssm:GetParameter",
            "ssm:GetParameters",
            "ssm:GetParametersByPath",
            "secretsmanager:GetSecretValue",
            "kms:Decrypt"
          ]
          Resource = "*"
        },
      ]
    })
  }

  inline_policy {
    name = "AllowSQSOperations"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Action = [
            "sqs:ReceiveMessage",
            "sqs:SendMessage",
            "sqs:DeleteMessage",
            "sqs:GetQueueAttributes"
          ]
          Resource = "*"
        },
      ]
    })
  }

  # コンテナからs3等にアクセスする場合、このロールにpolicyを追加
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${var.env}-${var.pj_prefix}-ecs-task-execution-role"
  path = "/"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "sts:AssumeRole"
        Sid    = ""
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  ]

  inline_policy {
    name = "AllowAllActions"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Action = [
            "sts:AssumeRole",
            "ssm:GetParameters",
            "secretsmanager:GetSecretValue",
            "kms:Decrypt"
          ]
          Resource = "*"
        },
      ]
    })
  }
}
