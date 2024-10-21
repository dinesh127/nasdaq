variable "aws_access_key" {
  description = "AWS access key"
  type        = string
}

variable "aws_secret_key" {
  description = "AWS secret key"
  type        = string
}

variable "region_singapore" {
  description = "AWS region for Singapore"
  type        = string
  default     = "ap-southeast-1"
}

variable "region_ireland" {
  description = "AWS region for Ireland"
  type        = string
  default     = "eu-west-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "ireland_ami" {
  description = "AMI ID"
  type        = string
  default     = "ami-012fdac573cd1044e"  # Replace with an actual AMI ID
}

variable "singapore_ami" {
  description = "AMI ID"
  type        = string
  default     = "ami-072ff22bbcc45a9a3"  # Replace with an actual AMI ID
}
