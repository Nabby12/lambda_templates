# ------------------------------------------------------------#
# Parameter
# ------------------------------------------------------------#
locals {
  # 1件あたりのキュー消化時間とリクエスト数から割り出す（最小台数の料金が安いのか？）
  # task_min_container               = var.env == "dev" ? 1 : 10
  task_min_container                  = var.env == "dev" ? 1 : 10 # 一時的に本番環境も「0」
  task_max_container                  = 30
  service_alarm_evaluation_periods    = 1
  service_scale_evaluation_periods    = 120
  service_scale_in_evaluation_periods = 300
  service_scaling_threshold           = var.env == "dev" ? 1 : 10
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
  min_capacity       = 0
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
      metric_interval_lower_bound = 0 # しきい値 +0
      metric_interval_upper_bound = 10
      scaling_adjustment          = local.task_min_container
    }
    step_adjustment {
      metric_interval_lower_bound = 10
      metric_interval_upper_bound = 20
      scaling_adjustment          = 20
    }
    step_adjustment {
      metric_interval_lower_bound = 20 # しきい値 +20
      metric_interval_upper_bound = 30
      scaling_adjustment          = 30
    }
    step_adjustment {
      metric_interval_lower_bound = 30
      scaling_adjustment          = local.task_max_container
    }
  }

  depends_on = [
    aws_appautoscaling_target.service_scaling_target
  ]
}

resource "aws_appautoscaling_policy" "service_scale_in_policy" {
  name               = "${var.env}-${var.pj_prefix}-service-scale-in-policy"
  policy_type        = "StepScaling"
  resource_id        = aws_appautoscaling_target.service_scaling_target.resource_id
  scalable_dimension = aws_appautoscaling_target.service_scaling_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.service_scaling_target.service_namespace

  step_scaling_policy_configuration {
    adjustment_type         = "ExactCapacity"
    cooldown                = 60
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_upper_bound = 1 - local.service_scaling_threshold
      scaling_adjustment          = 0
    }
    step_adjustment {
      metric_interval_lower_bound = 1 - local.service_scaling_threshold
      scaling_adjustment          = local.task_min_container
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
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = local.service_alarm_evaluation_periods
  threshold           = local.service_scaling_threshold

  metric_query {
    id          = "sumvisibleandnotvisivle"
    expression  = "visible+notvisible"
    label       = "SumVisibleAndNotVisivle"
    return_data = "true"
  }

  metric_query {
    id = "visible"

    metric {
      metric_name = "ApproximateNumberOfMessagesVisible"
      namespace   = "AWS/SQS"
      period      = local.service_scale_evaluation_periods
      stat        = "Average"
      unit        = "Count"

      dimensions = {
        QueueName = "${aws_sqs_queue.trigger_queue.name}"
      }
    }
  }
  metric_query {
    id = "notvisible"

    metric {
      metric_name = "ApproximateNumberOfMessagesNotVisible"
      namespace   = "AWS/SQS"
      period      = local.service_scale_evaluation_periods
      stat        = "Average"
      unit        = "Count"

      dimensions = {
        QueueName = "${aws_sqs_queue.trigger_queue.name}"
      }
    }
  }

  alarm_description = "Alarm if SQS queue messages is above threshold"
  alarm_actions = [
    "${aws_appautoscaling_policy.service_scaling_policy.arn}"
  ]

  depends_on = [
    aws_appautoscaling_policy.service_scaling_policy
  ]
}

resource "aws_cloudwatch_metric_alarm" "service_scale_in_alarm" {
  alarm_name          = "${var.env}-${var.pj_prefix}-service-scale-in-alarm"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = local.service_alarm_evaluation_periods
  threshold           = local.service_scaling_threshold

  metric_query {
    id          = "sumvisibleandnotvisivle"
    expression  = "visible+notvisible"
    label       = "SumVisibleAndNotVisivle"
    return_data = "true"
  }

  metric_query {
    id = "visible"

    metric {
      metric_name = "ApproximateNumberOfMessagesVisible"
      namespace   = "AWS/SQS"
      period      = local.service_scale_in_evaluation_periods
      stat        = "Average"
      unit        = "Count"

      dimensions = {
        QueueName = "${aws_sqs_queue.trigger_queue.name}"
      }
    }
  }
  metric_query {
    id = "notvisible"

    metric {
      metric_name = "ApproximateNumberOfMessagesNotVisible"
      namespace   = "AWS/SQS"
      period      = local.service_scale_in_evaluation_periods
      stat        = "Average"
      unit        = "Count"

      dimensions = {
        QueueName = "${aws_sqs_queue.trigger_queue.name}"
      }
    }
  }

  alarm_description = "Alarm if SQS queue messages is below threshold"
  alarm_actions = [
    "${aws_appautoscaling_policy.service_scale_in_policy.arn}"
  ]

  depends_on = [
    aws_appautoscaling_policy.service_scale_in_policy
  ]
}
