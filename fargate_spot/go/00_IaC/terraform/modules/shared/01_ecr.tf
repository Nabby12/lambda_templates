# ------------------------------------------------------------#
# ECR
# ------------------------------------------------------------#
resource "aws_ecr_repository" "ecr" {
  name                 = var.pj_prefix
  image_tag_mutability = "IMMUTABLE"
}

resource "aws_ecr_lifecycle_policy" "foopolicy" {
  repository = aws_ecr_repository.ecr.name

  policy = <<EOF
{
  "rules": [
    {
      "rulePriority": 10,
      "description": "Delete more than 5 images with the tag dev-*",
      "selection": {
        "tagStatus": "tagged",
        "tagPrefixList": [
          "dev-"
        ],
        "countType": "imageCountMoreThan",
        "countNumber": 5
      },
      "action": {
        "type": "expire"
      }
    },
    {
      "rulePriority": 20,
      "description": "Delete more than 5 images with the tag prd-*",
      "selection": {
        "tagStatus": "tagged",
        "tagPrefixList": [
          "prd-"
        ],
        "countType": "imageCountMoreThan",
        "countNumber": 5
      },
      "action": {
        "type": "expire"
      }
    }
  ]
}
EOF
}
