#Region
############################
variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

#VPC
############################
variable "vpc_cidr_block" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.246.12.0/24"
}

variable "gen_ai_dev_vpc" {
  description = "Configuration for the AWS VPC"
  type        = map(string)
  default     = {
    Name        = "gen-ai-dev-vpc"
    Environment = "Dev"
  }
}

#Subnets
############################
variable "subnet_cidr_blocks" {
  description = "CIDR blocks for subnets"
  type        = list(string)
  default     = ["10.246.12.0/26", "10.246.12.64/26", "10.246.12.128/26", "10.246.12.192/26"]
}

variable "availability_zones" {
  description = "Availability zones for subnets"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1a", "us-east-1b"]
}

#EC2 Instance
############################
variable "ec2_instance_subnet" {
  description = "Subnet ID for EC2 Instance"
  type        = string
  default     = "vpc"
}

variable "ec2_instance_ami" {
  description = "AMI ID for EC2 Instance"
  type        = string
  default     = "ami-079db87dc4c10ac91"
}

variable "ec2_instance_type" {
  description = "Instance type for EC2 Instance"
  type        = string
  default     = "t2.micro"
}

variable "ec2_instance_key_pair" {
  description = "Key Pair for EC2 Instance"
  type        = string
  default     = "praveenk_789"
}

#Routetables
############################
variable "public_route_table" {
  description = "Tags for Public Route Table"
  type        = map(string)
  default     = {
    Name        = "gen-ai-dev-public-rt"
    Environment = "Dev"
  }
}

variable "private_route_table" {
  description = "Tags for Private Route Table"
  type        = map(string)
  default     = {
    Name        = "gen-ai-dev-private-rt"
    Environment = "Dev"
  }
}

#IGW
############################
variable "gen_ai_dev_igw" {
  description = "Configuration for the Internet Gateway"
  type        = map(string)
  default     = {
    Name        = "gen-ai-dev-igw"
    Environment = "Dev"
  }
}

#Security Groups
############################
variable "gen_ai_ec2_sg" {
  description = "SG for EC2"
  type        = map(string)
  default     = {
    Name        = "gen_ai_ec2_sg"
    Environment = "Dev"
  }
}

variable "gen-ai-dev-instance" {
  description = "SG for EC2 Instance"
  type        = map(string)
  default     = {
    Name        = "gen-ai-dev-instance"
    Environment = "Dev"
  }
}
#EIP
############################
variable "gen-ai-dev-eip" {
  description = "Tags for Elastic IP"
  type        = map(string)
  default     = {
    Name        = "gen-ai-dev-eip"
    Environment = "Dev"
  }
}
#NAT GATEWAY
############################

variable "gen-ai-dev-nat-gateway" {
  description = "Tags for NAT Gateway"
  type        = map(string)
  default     = {
    Name        = "gen-ai-dev-nat-gateway"
    Environment = "Dev"
  }
}

# Security Group for RDS
############################
variable "rds_security_group" {
  description = "Security group for RDS instance"
  type        = map(string)
  default     = {
    Name        = "gen-ai-dev-rds-sg"
    Environment = "Dev"
  }
}

# VPC Endpoint
############################
variable "vpc_endpoint_name" {
  description = "Name for the VPC Endpoint"
  default     = "gen-ai-dev-endpoint"
}

variable "vpc_endpoint_service_name" {
  description = "Service name for RDS VPC Endpoint"
  default     = "com.amazonaws.us-east-1.rds"
}

# RDS Subnet Group
############################
variable "rds_subnet_group_name" {
  description = "Name for the RDS Subnet Group"
  default     = "gen-ai-dev-rds-subnet-group"
}

# ALB
############################
variable "alb_name" {
  description = "Name for the Application Load Balancer"
  default     = "gen-ai-dev-alb"
}

# Target Group
############################
variable "target_group_name" {
  description = "Name for the Target Group"
  default     = "gen-ai-dev-target-group"
}

# Listeners
############################
variable "alb_listener_port" {
  description = "Port for the ALB listener"
  default     = 80
}

variable "alb_listener_protocol" {
  description = "Protocol for the ALB listener"
  default     = "HTTP"
}

variable "github_repo_owner" {
  description = "GitHub repository owner"
  type        = string
  default     = "PraveenKasoju"
}

variable "github_repo_name" {
  description = "GitHub repository name"
  type        = string
  default     = "RFP-Gen-AI-IaaC"
}

variable "github_branch" {
  description = "GitHub branch to trigger the pipeline"
  type        = string
  default     = "main"
}

variable "codebuild_image" {
  description = "CodeBuild Docker image"
  type        = string
  default     = "aws/codebuild/standard:5.0"
}

variable "codepipeline_name" {
  description = "Name for the CodePipeline"
  type        = string
  default     = "gen-ai-dev-codepipeline"
}

variable "codebuild_project_name" {
  description = "Name for the CodeBuild project"
  type        = string
  default     = "gen-ai-dev-codebuild"
}
