resource "aws_security_group" "this" {
  name        = var.sg.name
  description = var.sg.description
  vpc_id      = var.vpc_id

  tags = {
    Name        = "${var.prefix.environment}-${var.prefix.name}-alb-sg"
    Environment = var.prefix.environment
    Terraform   = "Yes"
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "ingress_rules" {
  count = length(var.sg.ingress_rules)

  security_group_id = aws_security_group.this.id
  type              = "ingress"

  cidr_blocks = split(
    ",",
    lookup(
      var.sg.ingress_rules[count.index],
      "cidr_blocks",
    ),
  )
  from_port   = lookup(var.sg.ingress_rules[count.index], "from_port")
  to_port     = lookup(var.sg.ingress_rules[count.index], "to_port")
  protocol    = lookup(var.sg.ingress_rules[count.index], "protocol")
  description = lookup(var.sg.ingress_rules[count.index], "description", "Ingress Rule")
}

resource "aws_security_group_rule" "egress_rules" {
  count = length(var.sg.egress_rules)

  security_group_id = aws_security_group.this.id
  type              = "egress"
  cidr_blocks = split(
    ",",
    lookup(
      var.sg.egress_rules[count.index],
      "cidr_blocks",
    ),
  )
  from_port   = lookup(var.sg.egress_rules[count.index], "from_port")
  to_port     = lookup(var.sg.egress_rules[count.index], "to_port")
  protocol    = lookup(var.sg.egress_rules[count.index], "protocol")
  description = lookup(var.sg.egress_rules[count.index], "description")
}
