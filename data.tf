data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
data "aws_codestarconnections_connection" "main" {
  arn = var.connection_arn
}
data "aws_iam_role" "deployer" {
  count = (var.enable_aws_cicd == true) ? 1 : 0
  name  = (var.environment == "prod") ? "${var.tenant}-${var.name}-eks-deployer-iam-role-${data.aws_region.current.name}-prod" : "${var.tenant}-${var.name}-eks-deployer-iam-role-${data.aws_region.current.name}-nonprod"
}