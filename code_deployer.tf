resource "aws_codebuild_project" "deploy" {
  count          = (var.enable_aws_cicd == true) ? 1 : 0
  name           = "${var.tenant}-${var.name}-${var.pipeline_name}-deploy-${var.environment}"
  description    = "Managed by Magicorn"
  build_timeout  = var.build_timeout
  queued_timeout = var.queued_timeout
  service_role   = data.aws_iam_role.deployer[0].arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "public.ecr.aws/magicorn/tools-deploy:${var.deployer_version}"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "SERVICE_ROLE"
    privileged_mode             = false
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
    buildspec = var.deployspec
  }

  tags = {
    Name        = "${var.tenant}-${var.name}-${var.pipeline_name}-deploy-${var.environment}"
    Tenant      = var.tenant
    Project     = var.name
    Environment = var.environment
    Maintainer  = "Magicorn"
    Terraform   = "yes"
  }
}