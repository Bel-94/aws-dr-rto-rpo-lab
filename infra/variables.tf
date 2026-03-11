variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
}

variable "project_name" {
  description = "Project name used for naming resources"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
}

variable "private_app_subnet_cidrs" {
  description = "CIDR blocks for private app subnets"
  type        = list(string)
}

variable "private_db_subnet_cidrs" {
  description = "CIDR blocks for private DB subnets"
  type        = list(string)
}

#ECS task settings
variable "app_port" {
  description = "Port the app listens on"
  type        = number
  default     = 3000
}

variable "container_cpu" {
  description = "CPU units for the ECS task"
  type        = number
  default     = 256
}

variable "container_memory" {
  description = "Memory for the ECS task in MiB"
  type        = number
  default     = 512
}

variable "desired_count" {
  description = "Number of ECS tasks to run"
  type        = number
  default     = 1
}

#db variables
variable "db_name" {
  description = "Database name"
  type        = string
}

variable "db_username" {
  description = "Database master username"
  type        = string
}

variable "db_port" {
  description = "Database port"
  type        = number
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
}

#alarm threshold variables
variable "alb_5xx_threshold" {
  description = "Threshold for ALB 5xx errors alarm"
  type        = number
  default     = 5
}

variable "rds_cpu_threshold" {
  description = "Threshold for RDS CPU utilization alarm"
  type        = number
  default     = 80
}

variable "rds_connections_threshold" {
  description = "Threshold for RDS database connections alarm"
  type        = number
  default     = 20
}

