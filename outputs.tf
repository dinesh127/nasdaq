output "singapore_alb_dns_name" {
  value = aws_lb.singapore_lb.dns_name
}

output "ireland_alb_dns_name" {
  value = aws_lb.ireland_lb.dns_name
}

output "singapore_vpc_id" {
  value = aws_vpc.singapore_vpc.id
}

output "ireland_vpc_id" {
  value = aws_vpc.ireland_vpc.id
}

output "singapore_asg_name" {
  value = aws_autoscaling_group.singapore_asg.name
}

output "ireland_asg_name" {
  value = aws_autoscaling_group.ireland_asg.name
}
