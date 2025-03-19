variable "aws_region" {
  description = "AWS region"
  default     = "us-east-1"
}

variable "subnet_ids" {
  description = "List of subnet IDs for the Redis cluster"
  type        = list(string)
}

variable "allowed_cidr_blocks" {
  description = "CIDR blocks allowed to access Redis"
  type        = list(string)
  default     = ["0.0.0.0/0"] # Use com cuidado em produção
}

variable "node_type" {
  description = "Instance type for Redis nodes"
  default     = "cache.t2.micro"
}

variable "vpc_id" {
  description = "ID da VPC onde o Security Group será criado"
  default        = "vpc-471cf83a"
}
