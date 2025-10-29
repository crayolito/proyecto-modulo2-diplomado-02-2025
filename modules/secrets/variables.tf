variable "project_name" {
  description = "Nombre del proyecto"
  type        = string
}

variable "environment" {
  description = "Ambiente"
  type        = string
}

variable "db_username" {
  description = "Usuario de base de datos"
  type        = string
  default     = "admin"
}
