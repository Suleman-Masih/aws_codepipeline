resource "aws_security_group" "this" {
  name = "${var.prefix.environment}-${var.prefix.name}-ecs"
  vpc_id = var.vpc_id

  tags = {
    Name        = "${var.prefix.environment}-${var.prefix.name}-app-sg"
    Environment = var.prefix.environment
    Terraform   = "Yes"
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "this" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = -1
  source_security_group_id = var.alb_security_group
  security_group_id = aws_security_group.this.id
}


resource "aws_security_group_rule" "egress_rules" {
  security_group_id = aws_security_group.this.id
  type              = "egress"
  cidr_blocks = ["0.0.0.0/0"]
  from_port   = 0
  to_port     = 0
  protocol    = -1
}