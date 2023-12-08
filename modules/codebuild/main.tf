resource "aws_codebuild_project" "codebuild" {
  name         = "${var.prefix.environment}-${var.prefix.name}-codebuild"
  description  = "Build the application"
  service_role = var.codebuild_role

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "hashicorp/terraform:latest"
    type         = "LINUX_CONTAINER"
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "buildspec.yml"
  }
}