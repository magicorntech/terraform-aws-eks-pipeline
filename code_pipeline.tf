resource "aws_codepipeline" "main" {
  name     = "${var.tenant}-${var.name}-${var.pipeline_name}-pipeline-${var.environment}"
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    location = aws_s3_bucket.main.bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      namespace        = "SourceVariables"
      output_artifacts = ["SourceArtifact"]

      configuration = {
        ConnectionArn        = data.aws_codestarconnections_connection.main.arn
        FullRepositoryId     = var.repository
        BranchName           = var.branch
        OutputArtifactFormat = "CODEBUILD_CLONE_REF"
        DetectChanges        = var.detect_changes
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      namespace        = "BuildVariables"
      input_artifacts  = ["SourceArtifact"]
      output_artifacts = ["BuildArtifact"]

      configuration = {
        ProjectName = aws_codebuild_project.build.id
      }
    }
  }

  dynamic "stage" {
    for_each = (var.enable_deploy == true) ? [true] : []
    content {
      name = "Deploy"

      action {
        name             = "Build"
        category         = "Build"
        owner            = "AWS"
        provider         = "CodeBuild"
        version          = "1"
        input_artifacts  = ["SourceArtifact", "BuildArtifact"]
        output_artifacts = []

        configuration = {
          ProjectName     = aws_codebuild_project.deploy[0].id
          "PrimarySource" = "SourceArtifact"
        }
      }
    }
  }

  tags = {
    Name        = "${var.tenant}-${var.name}-${var.pipeline_name}-pipeline-${var.environment}"
    Tenant      = var.tenant
    Project     = var.name
    Environment = var.environment
    Maintainer  = "Magicorn"
    Terraform   = "yes"
  }
}