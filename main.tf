terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = var.aws_region
}

resource "aws_elasticache_subnet_group" "redis_subnet_group" {
  name       = "redis-subnet-group"
  subnet_ids = var.subnet_ids

  tags = {
    Name = "redis-subnet-group"
  }
}

data "aws_security_group" "existing_redis_sg" {
  filter {
    name   = "group-name"
    values = ["redis-security-group"]
  }

  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
}

resource "aws_security_group" "redis_sg" {
  count = length(data.aws_security_group.existing_redis_sg.id) > 0 ? 0 : 1

  name        = "redis-security-group"
  description = "Allow Redis access"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "redis-security-group"
  }
}

resource "aws_elasticache_cluster" "redis" {
  cluster_id           = "redis-cluster"
  engine               = "redis"
  node_type            = var.node_type
  num_cache_nodes      = 1
  parameter_group_name = "default.redis7"
  port                 = 6379
  subnet_group_name    = aws_elasticache_subnet_group.redis_subnet_group.name
  security_group_ids = length(data.aws_security_group.existing_redis_sg.id) > 0 ? [data.aws_security_group.existing_redis_sg.id] : [aws_security_group.redis_sg.id]

  tags = {
    Name = "redis-cluster"
  }
}
