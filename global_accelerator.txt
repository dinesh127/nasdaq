resource "aws_globalaccelerator_accelerator" "example" {
  name               = "example-accelerator"
  enabled            = true

  ip_address_type    = "IPV4"

  attributes {
    flow_logs_enabled = false
  }
}

resource "aws_globalaccelerator_listener" "example" {
  accelerator_arn    = aws_globalaccelerator_accelerator.example.id
  client_affinity    = "NONE"
  protocol           = "TCP"
  port_range {
    from_port        = 80
    to_port          = 80
  }
}

resource "aws_globalaccelerator_endpoint_group" "singapore" {
  listener_arn     = aws_globalaccelerator_listener.example.id
  endpoint_group_region = "ap-southeast-1"
  traffic_dial_percentage = 60.0

  endpoint_configuration {
    endpoint_id   = aws_lb.singapore_lb.arn
    weight        = 128
  }
}

resource "aws_globalaccelerator_endpoint_group" "ireland" {
  listener_arn     = aws_globalaccelerator_listener.example.id
  endpoint_group_region = "eu-west-1"
  traffic_dial_percentage = 30.0

  endpoint_configuration {
    endpoint_id   = aws_lb.ireland_lb.arn
    weight        = 128
  }
}

# resource "aws_globalaccelerator_endpoint_group" "us_east" {
#  listener_arn     = aws_globalaccelerator_listener.example.id
#  endpoint_group_region = "us-east-1"
#  traffic_dial_percentage = 10.0

# endpoint_configuration {
#    endpoint_id   = aws_lb.us_east_lb.arn
#    weight        = 128
#  }
#}
