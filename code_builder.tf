resource "aws_codebuild_project" "build" {
  name           = "${var.tenant}-${var.name}-${var.pipeline_name}-build-${var.environment}"
  description    = "Managed by Magicorn"
  build_timeout  = var.build_timeout
  queued_timeout = var.queued_timeout
  service_role   = aws_iam_role.codebuild_role.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  cache {
    type  = "LOCAL"
    modes = ["LOCAL_DOCKER_LAYER_CACHE"]
  }

  environment {
    compute_type                = var.compute_type
    image                       = var.image
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = var.privileged_mode
  }

  dynamic "vpc_config" {
    for_each = (var.vpc_enabled == true) ? [true] : []
    content {
      vpc_id             = var.vpc_id
      subnets            = var.subnet_ids
      security_group_ids = [aws_security_group.main.id]
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = var.buildspec
  }

  tags = {
    Name        = "${var.tenant}-${var.name}-${var.pipeline_name}-build-${var.environment}"
    Tenant      = var.tenant
    Project     = var.name
    Environment = var.environment
    Maintainer  = "Magicorn"
    Terraform   = "yes"
  }
}