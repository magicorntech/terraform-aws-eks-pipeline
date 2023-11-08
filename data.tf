data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
data "aws_codestarconnections_connection" "main" {
  arn = var.connection_arn
}