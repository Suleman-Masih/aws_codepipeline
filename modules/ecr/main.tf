resource "aws_ecr_repository" "ecr_repo" {
  name = "${var.prefix.environment}-${var.prefix.name}-${var.ecr.name}"
  # used to overwritten the image tag
  #https://docs.aws.amazon.com/AmazonECR/latest/userguide/image-tag-mutability.html
  image_tag_mutability = "MUTABLE"
  force_delete         = true

  image_scanning_configuration {
    #using automated image scans you can ensure container image vulnerabilities are found before getting pushed to production
    scan_on_push = true
  }
  tags = {
    Name        = "${var.prefix.environment}-${var.prefix.name}-${var.ecr.name}"
    Environment = var.prefix.environment
    Terraform   = "Yes"
  }


}

# ECR Lifecycle Policy Settings
resource "aws_ecr_lifecycle_policy" "ecr_repo_lifecycle_policy" {
  repository = aws_ecr_repository.ecr_repo.name
  policy = jsonencode({
    rules = [{
      rulePriority = var.ecr.rulePriority
      description  = var.ecr.description
      action = {
        type = "expire"
      }
      selection = {
        tagStatus   = "any"
        countType   = var.ecr.countType
        countNumber = var.ecr.countNumber
      }
    }]
  })
}
