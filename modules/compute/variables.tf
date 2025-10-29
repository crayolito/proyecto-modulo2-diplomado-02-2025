variable "project_name" {
  description = "Nombre del proyecto"
  type        = string
}

variable "environment" {
  description = "Ambiente"
  type        = string
}

variable "vpc_id" {
  description = "ID de la VPC"
  type        = string
}

variable "subnet_id" {
  description = "ID de la subred"
  type        = string
}

variable "instance_type" {
  description = "Tipo de instancia EC2"
  type        = string
  default     = "t3.micro"
}

variable "public_key" {
  description = "Clave pública SSH"
  type        = string
}

variable "security_group_ids" {
  description = "IDs de security groups a usar"
  type        = list(string)
  default     = null
}

variable "instance_profile_name" {
  description = "Nombre del instance profile IAM"
  type        = string
  default     = null
}
