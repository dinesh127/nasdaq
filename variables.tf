variable "aws_access_key" {
  description = "AWS access key"
  type        = string
}

variable "aws_secret_key" {
  description = "AWS secret key"
  type        = string
}
variable "region" {
  description = "The AWS region to deploy resources"
  type        = string
  default     = "ap-southeast-1"
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "172.16.0.0/16"
}

variable "public_subnet_cidr" {
  description = "The CIDR block for the public subnet"
  type        = string
  default     = "172.16.1.0/24"
}

variable "private_subnet1_cidr" {
  description = "The CIDR block for the first private subnet"
  type        = string
  default     = "172.16.2.0/24"
}

variable "private_subnet2_cidr" {
  description = "The CIDR block for the second private subnet"
  type        = string
  default     = "172.16.3.0/24"
}

variable "ami_id" {
  description = "The ID of the AMI to use for the EC2 instances"
  type        = string
  default     = "ami-0fd973a84b3c8067a"
}

variable "instance_type" {
  description = "The type of instance to use"
  type        = string
  default     = "t2.micro"
}

variable "bucket_name" {
  description = "The name of the S3 bucket for storing logs"
  type        = string
  default     = "dini-dev-tf-state-bucket"
}

variable "key_name" {
  description = "Name of the key pair"
  type        = string
  default     = "model-1"

}
