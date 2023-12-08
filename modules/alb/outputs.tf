output "target_group" {
  value = aws_alb_target_group.default
}

output "alb_dns_name" {
  value = aws_lb.default.dns_name
}

output "alb_zone_id" {
  value = aws_lb.default.zone_id
}