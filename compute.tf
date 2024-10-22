data "aws_availability_zones" "available" {}

resource "aws_lb" "app_lb" {
  name               = "app-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [
    aws_subnet.singapore_public_subnet.id,
    aws_subnet.singapore_private_subnet1.id
  ]
}


resource "aws_lb_target_group" "app_tg" {
  name     = "app-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.singapore_vpc.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener" "app_lb_listener" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}

resource "aws_launch_template" "app_lt" {
  name_prefix   = "app-template-"
  image_id      = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name  # Add the key_name here
  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.ec2_sg.id]
  }
user_data = base64encode(<<EOF
#!/bin/bash
# Install htop
sudo apt-get install -y htop

# Create SSL Certificate using bncert-tool
sudo /opt/bitnami/bncert-tool <<EOF2
www.dininasdaq.com
yes
yes
yes
rdinesh.127@gmail.com
yes
EOF2

EOF
)
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "example" {
  vpc_zone_identifier  = [aws_subnet.singapore_public_subnet.id]
  target_group_arns    = [aws_lb_target_group.app_tg.arn]
  launch_template {
    id      = aws_launch_template.app_lt.id
    version = "$Latest"
  }

  min_size           = 1
  max_size           = 3
  desired_capacity   = 1

  tag {
    key                 = "Name"
    value               = "example-asg"
    propagate_at_launch = true
  }
}
