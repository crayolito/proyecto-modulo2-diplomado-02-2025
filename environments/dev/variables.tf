variable "aws_region" {
  description = "Región AWS"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Nombre del proyecto"
  type        = string
  default     = "iac-security"
}

variable "environment" {
  description = "Ambiente"
  type        = string
  default     = "dev"
}
