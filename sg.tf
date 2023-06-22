resource "aws_security_group" "main" {
  name        = "${var.tenant}-${var.name}-${var.pipeline_name}-codebuild-sg-${var.environment}"
  description = "Managed by Magicorn"
  vpc_id      = var.vpc_id

  ingress {
    protocol  = "-1"
    from_port = 0
    to_port   = 0
    self      = true
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.tenant}-${var.name}-${var.pipeline_name}-codebuild-sg-${var.environment}"
    Tenant      = var.tenant
    Project     = var.name
    Environment = var.environment
    Maintainer  = "Magicorn"
    Terraform   = "yes"
  }
}