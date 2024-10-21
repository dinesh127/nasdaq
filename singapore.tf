resource "aws_vpc" "singapore_vpc" {
  provider   = aws.singapore
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "singapore_public_subnet" {
  provider                = aws.singapore
  vpc_id                  = aws_vpc.singapore_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "ap-southeast-1a"
}

resource "aws_subnet" "singapore_private_subnet" {
  provider   = aws.singapore
  vpc_id     = aws_vpc.singapore_vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone       = "ap-southeast-1b"
}

resource "aws_subnet" "singapore_public_subnet2" {
  provider                = aws.singapore
  vpc_id                  = aws_vpc.singapore_vpc.id
  cidr_block              = "10.0.3.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "ap-southeast-1b"
}

resource "aws_internet_gateway" "singapore_igw" {
  provider = aws.singapore
  vpc_id   = aws_vpc.singapore_vpc.id
}

resource "aws_route" "singapore_route" {
  provider             = aws.singapore
  route_table_id       = aws_route_table.singapore_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id           = aws_internet_gateway.singapore_igw.id
}


resource "aws_security_group" "singapore_lb_sg" {
  provider = aws.singapore
  vpc_id   = aws_vpc.singapore_vpc.id

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

resource "aws_lb" "singapore_lb" {
  provider            = aws.singapore
  name                = "singapore-lb"
  internal            = false
  load_balancer_type  = "application"
  security_groups     = [aws_security_group.singapore_lb_sg.id]
  subnets             = [
    aws_subnet.singapore_public_subnet.id,
    aws_subnet.singapore_public_subnet2.id,
  ]
}

resource "aws_lb_target_group" "singapore_tg" {
  provider = aws.singapore
  name     = "singapore-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.singapore_vpc.id
}

resource "aws_lb_listener" "singapore_listener" {
  provider           = aws.singapore
  load_balancer_arn  = aws_lb.singapore_lb.arn
  port               = 80
  protocol           = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.singapore_tg.arn
  }
}

resource "aws_launch_template" "singapore_lt" {
  provider                = aws.singapore
  name                    = "singapore-lt"
  image_id                = var.singapore_ami
  instance_type           = var.instance_type
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
AWS_ACCESS_KEY_ID = os.getenv('AWS_ACCESS_KEY_ID')
AWS_SECRET_ACCESS_KEY = os.getenv('AWS_SECRET_ACCESS_KEY')
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

resource "aws_autoscaling_group" "singapore_asg" {
  provider              = aws.singapore
  vpc_zone_identifier   = [
    aws_subnet.singapore_public_subnet.id,
    aws_subnet.singapore_public_subnet2.id,
  ]
  launch_template {
    id                  = aws_launch_template.singapore_lt.id
    version             = "$Latest"
  }
  target_group_arns     = [aws_lb_target_group.singapore_tg.arn]
  min_size              = 1
  max_size              = 3
  desired_capacity      = 1
  depends_on            = [aws_lb.singapore_lb]
}

resource "aws_dynamodb_table_replica" "singapore_dynamo_replica" {
  provider              = aws.singapore
  global_table_arn      = aws_dynamodb_table.ireland_dynamo.arn
  depends_on            = [aws_dynamodb_table.ireland_dynamo]
}

resource "aws_vpc_peering_connection_accepter" "accept_ireland_to_singapore" {
  provider                = aws.singapore
  vpc_peering_connection_id = aws_vpc_peering_connection.ireland_to_singapore.id
  auto_accept             = true

  tags = {
    Name = "Accept Ireland to Singapore Peering"
  }
}

resource "aws_route_table" "singapore_route_table" {
  provider = aws.singapore
  vpc_id   = aws_vpc.singapore_vpc.id
}

resource "aws_route" "route_to_ireland" {
  provider                = aws.singapore
  route_table_id          = aws_route_table.singapore_route_table.id
  destination_cidr_block  = aws_vpc.ireland_vpc.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.ireland_to_singapore.id
}
