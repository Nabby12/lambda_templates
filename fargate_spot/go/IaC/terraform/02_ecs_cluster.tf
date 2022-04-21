# ------------------------------------------------------------#
# Cluster
# ------------------------------------------------------------#
# ClusterはDev, Prd共通
resource "aws_ecs_cluster" "cluster" {
  name = "${var.pj_prefix}-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_ecs_cluster_capacity_providers" "capacity_providers" {
  cluster_name = aws_ecs_cluster.cluster.name

  capacity_providers = ["FARGATE_SPOT"]
}
