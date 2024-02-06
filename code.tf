# VPC
############################

resource "aws_vpc" "gen_ai_dev_vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name        = var.gen_ai_dev_vpc["Name"]
    Environment = var.gen_ai_dev_vpc["Environment"]
  }
}


# Public Subnets
############################

resource "aws_subnet" "gen_ai_dev_public_subnet" {
  count                  = 2
  vpc_id                 = aws_vpc.gen_ai_dev_vpc.id
  cidr_block             = var.subnet_cidr_blocks[count.index]
  availability_zone      = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name        = "gen-ai-dev-public-subnet-${count.index + 1}"
    Environment = "Dev"
  }
}

# Private Subnets
############################

resource "aws_subnet" "gen_ai_dev_private_subnet" {
  count         = 2
  vpc_id        = aws_vpc.gen_ai_dev_vpc.id
  cidr_block    = var.subnet_cidr_blocks[count.index + 2]
  availability_zone = var.availability_zones[count.index + 2]

  tags = {
    Name        = "gen-ai-dev-private-subnet-${count.index + 1}"
    Environment = "Dev"
  }
}

# Public Route Table
############################

resource "aws_route_table" "gen_ai_dev_public_rt" {
  vpc_id = aws_vpc.gen_ai_dev_vpc.id
  tags   = var.public_route_table
}

# Internet Gateway
############################

resource "aws_internet_gateway" "gen_ai_dev_igw" {
  vpc_id = aws_vpc.gen_ai_dev_vpc.id
  tags   = var.gen_ai_dev_igw
}

# Security Group for EC2
############################

resource "aws_security_group" "gen_ai_ec2_sg" {
  name        = var.gen_ai_ec2_sg["Name"]
  description = "Security group for EC2 instances"
  vpc_id      = aws_vpc.gen_ai_dev_vpc.id

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  tags = var.gen_ai_ec2_sg
}

# Security Group for ALB
############################

resource "aws_security_group" "alb_sg" {
  name        = "gen_ai_alb_sg"
  description = "Security group for ALB"
  vpc_id      = aws_vpc.gen_ai_dev_vpc.id
  tags        = var.gen_ai_ec2_sg
}

# Public Route Table Association
############################

resource "aws_route_table_association" "gen_ai_dev_public_subnet_association" {
  count          = 2
  subnet_id      = aws_subnet.gen_ai_dev_public_subnet[count.index].id
  route_table_id = aws_route_table.gen_ai_dev_public_rt.id
}

# Private Route Table
############################

resource "aws_route_table" "gen_ai_dev_private_rt" {
  vpc_id = aws_vpc.gen_ai_dev_vpc.id
  tags   = var.private_route_table
}

# EC2 Instance
############################

resource "aws_instance" "gen_ai_dev_instance" {
  ami           = var.ec2_instance_ami
  instance_type = var.ec2_instance_type
  subnet_id     = aws_subnet.gen_ai_dev_public_subnet[0].id
  key_name      = var.ec2_instance_key_pair
  vpc_security_group_ids = [aws_security_group.gen_ai_ec2_sg.id]

  tags = var.gen-ai-dev-instance
}

# Elastic IP (EIP) for NAT Gateway
############################

resource "aws_eip" "gen_ai_dev_nat_gateway_eip" {
  instance = null # No instance associated with EIP for NAT Gateway
  tags     = var.gen-ai-dev-eip
}

# NAT Gateway
############################

resource "aws_nat_gateway" "gen_ai_dev_nat_gateway" {
  allocation_id = aws_eip.gen_ai_dev_nat_gateway_eip.id
  subnet_id     = aws_subnet.gen_ai_dev_public_subnet[0].id # Adjust this based on your setup

  tags = var.gen-ai-dev-nat-gateway
}

# Security Group for RDS
############################
resource "aws_security_group" "gen_ai_dev_rds_sg" {
  name        = var.rds_security_group["Name"]
  description = "Security group for RDS"
  vpc_id      = aws_vpc.gen_ai_dev_vpc.id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    security_groups = [aws_security_group.gen_ai_ec2_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.rds_security_group
}

# VPC Endpoint
############################
resource "aws_vpc_endpoint" "gen_ai_dev_vpc_endpoint" {
  vpc_id       = aws_vpc.gen_ai_dev_vpc.id
  service_name = var.vpc_endpoint_service_name

  private_dns_enabled = true

  security_group_ids = [aws_security_group.gen_ai_ec2_sg.id]  # Use .id to get the security group ID

  vpc_endpoint_type = "Interface"

  tags = {
    Name        = var.vpc_endpoint_name
    Environment = "Dev"
  }
}


# RDS Subnet Group
############################
resource "aws_db_subnet_group" "gen_ai_dev_rds_subnet_group" {
  name        = var.rds_subnet_group_name
  description = "Subnet group for RDS"
  subnet_ids  = aws_subnet.gen_ai_dev_private_subnet[*].id
}

# Target Group
############################
resource "aws_lb_target_group" "gen_ai_dev_target_group" {
  name        = var.target_group_name
  port        = var.alb_listener_port
  protocol    = var.alb_listener_protocol
  vpc_id      = aws_vpc.gen_ai_dev_vpc.id
}

# Application Load Balancer (ALB)
############################
resource "aws_lb" "gen_ai_dev_alb" {
  name               = var.alb_name
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = aws_subnet.gen_ai_dev_public_subnet[*].id

  enable_deletion_protection = false

  enable_http2 = true

  tags = {
    Name        = var.alb_name
    Environment = "Dev"
  }
}

# ALB Listener
############################
resource "aws_lb_listener" "gen_ai_dev_listener" {
  load_balancer_arn = aws_lb.gen_ai_dev_alb.arn
  port              = var.alb_listener_port
  protocol          = var.alb_listener_protocol

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.gen_ai_dev_target_group.arn
  }
}

# EC2 Instance Attachment to Target Group
############################
resource "aws_lb_target_group_attachment" "gen_ai_dev_target_attachment" {
  target_group_arn  = aws_lb_target_group.gen_ai_dev_target_group.arn
  target_id         = aws_instance.gen_ai_dev_instance.id
}


# Create CodeStar Connection
############################
resource "aws_iam_user" "iam_demo8" {
  name = "iam-demo8"
}

resource "aws_iam_user_policy" "iam_demo8_policy" {
  name       = "iam-demo2-policy"
  user       = aws_iam_user.iam_demo8.name
  policy     = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = "iam:CreateRole",
        Resource = "*",
      },
    ],
  })
}


resource "aws_codestarconnections_connection" "github_connection" {
  name          = "github-connection"
  provider_type = "GitHub"
}

# CodeBuild Project
############################
resource "aws_codebuild_project" "codebuild_project" {
  name = var.codebuild_project_name

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = var.codebuild_image
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
  }

  source {
    type            = "GITHUB"
    location        = "https://github.com/${var.github_repo_owner}/${var.github_repo_name}"
    buildspec        = "buildspec.yml"
  }

  service_role = "arn:aws:iam::506236563550:role/CodeBuildServiceRole"
}

# CodePipeline
############################
resource "aws_codepipeline" "codepipeline" {
  name     = var.codepipeline_name
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    location = aws_s3_bucket.codepipeline_artifacts.bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "SourceAction"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["codepipeline_source_output"]

      configuration = {
        ConnectionArn       = aws_codestarconnections_connection.github_connection.arn
        FullRepositoryId    = "${var.github_repo_owner}/${var.github_repo_name}"
        BranchName           = var.github_branch
        OutputArtifactFormat = "CODEPIPELINE"
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "BuildAction"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["codepipeline_source_output"]
      output_artifacts = ["codepipeline_build_output"]
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.codebuild_project.name
      }
    }
  }
}

# IAM Role for CodePipeline
############################
resource "aws_iam_role" "codepipeline_role" {
  name = "codepipeline-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codepipeline.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

# S3 Bucket for CodePipeline artifacts
############################
resource "aws_s3_bucket" "codepipeline_artifacts" {
  bucket = "codepipeline-gen-ai-bucket"
}


