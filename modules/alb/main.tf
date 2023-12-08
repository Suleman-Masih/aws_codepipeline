resource "aws_lb" "default" {
  name               = "${var.prefix.environment}-${var.prefix.name}-${var.alb.name}"
  internal           = var.alb.internal
  load_balancer_type = var.alb.load_balancer_type
  security_groups    = [var.alb_sg]
  subnets            = var.subnet_ids

  enable_deletion_protection = var.alb.enable_deletion_protection

  tags = {
    Name        = "${var.prefix.environment}-${var.prefix.name}-${var.alb.name}"
    Environment = var.prefix.environment
  }
}

resource "aws_alb_target_group" "default" {
  name        = "${var.prefix.environment}-${var.prefix.name}-${var.alb.name}"
  port        = var.alb.target_group_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    healthy_threshold   = var.alb.health_check.healthy_threshold
    interval            = var.alb.health_check.interval
    protocol            = var.alb.health_check.protocol
    matcher             = var.alb.health_check.matcher
    timeout             = var.alb.health_check.timeout
    path                = var.alb.health_check.path
    unhealthy_threshold = var.alb.health_check.unhealthy_threshold
  }

  tags = {
    Name        = "${var.prefix.environment}-${var.prefix.name}-${var.alb.name}"
    Environment = var.prefix.environment
  }

}

resource "aws_alb_listener" "http" {
  load_balancer_arn = aws_lb.default.id
  port              = 80
  protocol          = "HTTP"

  default_action {
    # target_group_arn = aws_alb_target_group.default.id  ####am attaching this here because of the https needs certificate
    # type             = "forward"  ####am attaching this here because of the https needs certificate
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_alb_listener" "https" {
  load_balancer_arn = aws_lb.default.id
  port              = 443
  protocol          = "HTTPS"

  ssl_policy = "ELBSecurityPolicy-2016-08"
  #  certificate_arn = var.alb.certificate_arn

  default_action {
    target_group_arn = aws_alb_target_group.default.id
    type             = "forward"
  }
}
