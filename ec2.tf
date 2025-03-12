terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = "eu-west-2"
}

# Define instance type variable
variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

# AMI ID for all instances
variable "ami_id" {
  description = "AMI ID for all instances"
  type        = string
  default     = "ami-06cff85354b67982b"
}

# Retrieve all subnets in the specified VPC with a Name tag containing "public"
data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = ["vpc-07fc8bac920f81827"]
  }

  filter {
    name   = "tag:Name"
    values = ["*public*"]
  }
}

# Convert the returned list of subnet IDs and select the first one
locals {
  selected_public_subnet = element(data.aws_subnets.public.ids, 0)
}

# EC2 instances for app servers (2 instances)
resource "aws_instance" "app_servers" {
  ami                         = var.ami_id
  count                       = 2
  instance_type               = var.instance_type
  subnet_id                   = local.selected_public_subnet
  associate_public_ip_address = true
  security_groups             = ["sg-0947e510ceb323515"]
  key_name                    = "hush"

  tags = {
    Name = "app_server"
  }
}

# EC2 instance for the ansible server
resource "aws_instance" "ansible_server" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = local.selected_public_subnet
  associate_public_ip_address = true
  security_groups             = ["sg-0947e510ceb323515"]
  key_name                    = "hush"
  user_data                   = file("install_ansible.sh")  # Ensure this file exists or remove this line

  tags = {
    Name = "ansible_controller"
  }
}

# EC2 instances for web servers (2 instances)
resource "aws_instance" "web_servers" {
  ami                         = var.ami_id
  count                       = 2
  instance_type               = var.instance_type
  subnet_id                   = local.selected_public_subnet
  associate_public_ip_address = true
  security_groups             = ["sg-0947e510ceb323515"]
  key_name                    = "hush"

  tags = {
    Name = "web_server"
  }
}
