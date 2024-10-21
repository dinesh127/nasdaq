resource "aws_vpc" "ireland_vpc" {
  provider   = aws.ireland
  cidr_block = "172.16.0.0/16"
}

resource "aws_subnet" "ireland_public_subnet" {
  provider                = aws.ireland
  vpc_id                  = aws_vpc.ireland_vpc.id
  cidr_block              = "172.16.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "eu-west-1a"
}

resource "aws_subnet" "ireland_private_subnet" {
  provider   = aws.ireland
  vpc_id     = aws_vpc.ireland_vpc.id
  cidr_block = "172.16.2.0/24"
  availability_zone       = "eu-west-1b"
}

resource "aws_subnet" "ireland_public_subnet2" {
  provider                = aws.ireland
  vpc_id                  = aws_vpc.ireland_vpc.id
  cidr_block              = "172.16.3.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "eu-west-1b"
}

resource "aws_internet_gateway" "ireland_igw" {
  provider = aws.ireland
  vpc_id   = aws_vpc.ireland_vpc.id
}

resource "aws_route" "ireland_route" {
  provider             = aws.ireland
  route_table_id       = aws_route_table.ireland_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id           = aws_internet_gateway.ireland_igw.id
}

resource "aws_security_group" "ireland_lb_sg" {
  provider = aws.ireland
  vpc_id   = aws_vpc.ireland_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "ireland_lb" {
  provider            = aws.ireland
  name                = "ireland-lb"
  internal            = false
  load_balancer_type  = "application"
  security_groups     = [aws_security_group.ireland_lb_sg.id]
  subnets             = [
    aws_subnet.ireland_public_subnet.id,
    aws_subnet.ireland_public_subnet2.id,
  ]
}

resource "aws_lb_target_group" "ireland_tg" {
  provider = aws.ireland
  name     = "ireland-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.ireland_vpc.id
}

resource "aws_lb_listener" "ireland_listener" {
  provider           = aws.ireland
  load_balancer_arn  = aws_lb.ireland_lb.arn
  port               = 80
  protocol           = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ireland_tg.arn
  }
}

resource "aws_launch_template" "ireland_lt" {
  provider         = aws.ireland
  name             = "ireland-lt"
  image_id         = var.ireland_ami
  instance_type    = var.instance_type
  user_data     = base64encode(<<-EOF
<powershell>
# Step 1: Install Python
    Invoke-WebRequest -Uri "https://www.python.org/ftp/python/3.9.7/python-3.9.7-amd64.exe" -OutFile "C:\\python-3.9.7-amd64.exe"
    Start-Process -FilePath "C:\\python-3.9.7-amd64.exe" -ArgumentList "/quiet InstallAllUsers=1 PrependPath=1" -Wait

    # Step 2: Set Python Environment Variable
    [System.Environment]::SetEnvironmentVariable("Path", $Env:Path + ";C:\\Python39", "Machine")

    # Step 3: Download the Combined Script
    Invoke-WebRequest -Uri "https://github.com/dinesh127/nasdaq/blob/Assignment/install_iis.py" -OutFile "C:\\install_iis.py"

    # Step 4: Run the Combined Script
    python "C:\\install_iis.py"

    # Step 5: Upload Logs to S3 using Python
    $pythonScript = @"
import boto3
import os

# Fetch AWS credentials from environment variables
AWS_ACCESS_KEY_ID = "${aws_access_key}"
AWS_SECRET_ACCESS_KEY = "${aws_secret_key}"
AWS_REGION = 'your_aws_region'

# Configure S3 client
s3_client = boto3.client(
    's3',
    aws_access_key_id=AWS_ACCESS_KEY_ID,
    aws_secret_access_key=AWS_SECRET_ACCESS_KEY,
    region_name=AWS_REGION
)

# Define the log file path and S3 bucket details
log_file_path = 'C:\\ProgramData\\Amazon\\EC2-Windows\\Launch\\Log\\cloud-init-output.log'
bucket_name = 'dini-dev-tf-state-bucket'
key_name = 'logs/cloud-init-output.log'

# Upload the log file to S3
try:
    s3_client.upload_file(log_file_path, bucket_name, key_name)
    print('File uploaded successfully.')
except Exception as e:
    print(f'Failed to upload file: {e}')
"@

# Write the Python script to a file
$pythonScriptPath = "C:\\upload_to_s3.py"
[System.IO.File]::WriteAllText($pythonScriptPath, $pythonScript)

# Run the Python script
python $pythonScriptPath
</powershell>
EOF
)
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "ireland_asg" {
  provider              = aws.ireland
  vpc_zone_identifier   = [
    aws_subnet.ireland_public_subnet.id,
    aws_subnet.ireland_public_subnet2.id,
  ]
  launch_template {
    id                  = aws_launch_template.ireland_lt.id
    version             = "$Latest"
  }
  target_group_arns     = [aws_lb_target_group.ireland_tg.arn]
  min_size              = 1
  max_size              = 3
  desired_capacity      = 1
  depends_on            = [aws_lb.ireland_lb]
}

resource "aws_dynamodb_table" "ireland_dynamo" {
  provider          = aws.ireland
  name              = "GlobalTable"
  billing_mode      = "PAY_PER_REQUEST"
  hash_key          = "id"
  attribute {
    name = "id"
    type = "S"
  }
}

resource "aws_vpc_peering_connection" "ireland_to_singapore" {
  provider           = aws.ireland
  vpc_id             = aws_vpc.ireland_vpc.id
  peer_vpc_id        = aws_vpc.singapore_vpc.id
  peer_region        = "ap-southeast-1"

  tags = {
    Name = "Ireland to Singapore Peering"
  }
}

resource "aws_route" "route_to_singapore" {
  provider              = aws.ireland
  route_table_id        = aws_route_table.ireland_route_table.id
  destination_cidr_block = aws_vpc.singapore_vpc.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.ireland_to_singapore.id
}


resource "aws_route_table" "ireland_route_table" {
  provider = aws.ireland
  vpc_id   = aws_vpc.ireland_vpc.id
}
