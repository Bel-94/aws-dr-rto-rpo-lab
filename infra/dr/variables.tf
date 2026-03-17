variable "app_port" {
  description = "Port the app listens on"
  type        = number
  default     = 3000
}

variable "snapshot_id" {
  description = "ID of the DR snapshot copy to restore from"
  type        = string
}

variable "ecr_image_url" {
  description = "ECR image URL to use in the DR task definition"
  type        = string
}

variable "execution_role_arn" {
  description = "ECS task execution role ARN"
  type        = string
}

variable "db_port" {
  description = "Database port"
  type        = number
  default     = 5432
}

variable "db_name" {
  description = "Database name"
  type        = string
}

variable "db_username" {
  description = "Database username"
  type        = string
}

variable "secret_arn" {
  description = "ARN of the Secrets Manager secret for DB credentials"
  type        = string
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
