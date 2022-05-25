# ------------------------------------------------------------#
# Parameter
# ------------------------------------------------------------#
locals {
  # 1件あたりのキュー消化時間とリクエスト数から割り出す（最小台数の料金が安いのか？）
  # task_min_container               = var.env == "dev" ? 0 : 20
  task_min_container               = var.env == "dev" ? 0 : 0 # 一時的に本番環境も「0」
  task_scale_out_min_container     = 3
  task_max_container               = 10
  service_scale_evaluation_periods = 1
  service_scaling_threshold        = 3
}

# ------------------------------------------------------------#
# IAMRole
# ------------------------------------------------------------#
resource "aws_iam_role" "service_auto_scaling_role" {
  name = "${var.env}-${var.pj_prefix}-service-auto-scaling-role"
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
            "application-autoscaling.amazonaws.com"
          ]
        }
      },
    ]
  })

  inline_policy {
    name = "AllowScalingOperations"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Action = [
            "application-autoscaling:*",
            "cloudwatch:DescribeAlarms",
            "cloudwatch:PutMetricAlarm",
            "ecs:DescribeServices",
            "ecs:UpdateService"
          ]
          Resource = "*"
        },
      ]
    })
  }
}

# ------------------------------------------------------------#
# Auto Scaling
# ------------------------------------------------------------#
resource "aws_appautoscaling_target" "service_scaling_target" {
  min_capacity       = local.task_min_container
  max_capacity       = local.task_max_container
  resource_id        = "service/${var.cluster_name}/${aws_ecs_service.ecs_service.name}"
  role_arn           = aws_iam_role.service_auto_scaling_role.arn
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"

  depends_on = [
    aws_ecs_service.ecs_service,
    aws_iam_role.service_auto_scaling_role
  ]
}

resource "aws_appautoscaling_policy" "service_scaling_policy" {
  name               = "${var.env}-${var.pj_prefix}-service-scaling-policy"
  policy_type        = "StepScaling"
  resource_id        = aws_appautoscaling_target.service_scaling_target.resource_id
  scalable_dimension = aws_appautoscaling_target.service_scaling_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.service_scaling_target.service_namespace

  step_scaling_policy_configuration {
    adjustment_type         = "ExactCapacity"
    cooldown                = 60
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_upper_bound = 0 # しきい値からプラスマイナス「0」
      scaling_adjustment          = local.task_min_container
    }
    step_adjustment {
      metric_interval_lower_bound = 0
      metric_interval_upper_bound = 3
      scaling_adjustment          = local.task_scale_out_min_container
    }
    step_adjustment {
      metric_interval_lower_bound = 3 # しきい値からプラス「3」
      metric_interval_upper_bound = 6
      scaling_adjustment          = 5
    }
    step_adjustment {
      metric_interval_lower_bound = 6
      scaling_adjustment          = local.task_max_container
    }
  }

  depends_on = [
    aws_appautoscaling_target.service_scaling_target
  ]
}

# ------------------------------------------------------------#
# CloudWatch Alarm
# ------------------------------------------------------------#
resource "aws_cloudwatch_metric_alarm" "service_scaling_alarm" {
  alarm_name          = "${var.env}-${var.pj_prefix}-service-scaling-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = local.service_scale_evaluation_periods
  metric_name         = "ApproximateNumberOfMessagesVisible"
  namespace           = "AWS/SQS"
  period              = "60"
  statistic           = "Average"
  unit                = "Count"
  threshold           = local.service_scaling_threshold

  dimensions = {
    QueueName = "${aws_sqs_queue.trigger_queue.name}"
  }

  alarm_description = "Alarm if SQS queue messages is above threshold"
  alarm_actions = [
    "${aws_appautoscaling_policy.service_scaling_policy.arn}"
  ]

  depends_on = [
    aws_appautoscaling_policy.service_scaling_policy
  ]
}
