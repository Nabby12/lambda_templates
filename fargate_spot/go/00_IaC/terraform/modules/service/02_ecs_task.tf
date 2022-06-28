# ------------------------------------------------------------#
# Parameter
# ------------------------------------------------------------#
locals {
  task_cpu    = 512
  task_memory = 1024
}

# ------------------------------------------------------------#
# CloudWatch LogGroup
# ------------------------------------------------------------#
resource "aws_cloudwatch_log_group" "log_group" {
  name = "ecs/${var.env}-${var.pj_prefix}-ecs-task"
}

# ------------------------------------------------------------#
# Task Definition
# ------------------------------------------------------------#
resource "aws_ecs_task_definition" "task_definition" {
  family                   = "${var.env}-${var.pj_prefix}-ecs-task"
  requires_compatibilities = ["FARGATE"]
  cpu                      = local.task_cpu
  memory                   = local.task_memory
  network_mode             = "awsvpc"
  execution_role_arn       = var.ecs_task_execution_role_arn
  task_role_arn            = var.ecs_task_role_arn
  runtime_platform {
    cpu_architecture        = "X86_64" # Fargate Spot は Graviton2（arm64）に未対応
    operating_system_family = "LINUX"
  }
  container_definitions = jsonencode([
    {
      name  = "${var.env}-${var.pj_prefix}-container",
      image = "${var.aws_account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/${var.pj_prefix}:${var.image_version}",
      secrets : [
        {
          "name" : "ENV",
          "valueFrom" : "${aws_ssm_parameter.env.arn}"
        },
        {
          "name" : "AWS_REGION",
          "valueFrom" : "${aws_ssm_parameter.aws_region.arn}"
        },
        {
          "name" : "SQS_END_POINT",
          "valueFrom" : "${aws_ssm_parameter.sqs_end_point.arn}"
        },
        {
          "name" : "TRIGGER_QUEUE_URL",
          "valueFrom" : "${aws_ssm_parameter.trigger_queue_url.arn}"
        }
      ],
      environment : [
        {
          "name" : "TZ",
          "value" : "Asia/Tokyo"
        }
      ],
      logConfiguration : {
        logDriver : "awslogs",
        options : {
          awslogs-region : "${var.aws_region}",
          awslogs-group : "${aws_cloudwatch_log_group.log_group.id}"
          awslogs-stream-prefix : "ecs",
        }
        essential = true,
      },
      stopTimeout : 120,
    }
  ])
}
