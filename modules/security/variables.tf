variable "project_name" {
  description = "Nombre del proyecto"
  type        = string
}

variable "environment" {
  description = "Ambiente"
  type        = string
}

# VPC -> Virtual Private Cloud -> Nube Privada Virtual
# Es la red privada virtual en AWS 
variable "vpc_id" {
  description = "ID de la VPC"
  type        = string
}


# CIDR -> Classless Inter-Domain Routing -> Sistema de Enrutamiento de Redes
# Define el rango de direcciones IP de tu red.
variable "vpc_cidr" {
  description = "CIDR de la VPC"
  type        = string
}

# ARN -> Amazon Resource Name -> Identificador único que AWS asigna a cada recurso
# Es un identificador unico para un recurso en AWS.
variable "bucket_arn" {
  description = "ARN del bucket S3"
  type        = string
}

variable "allowed_ssh_cidrs" {
  description = "CIDRs permitidos para SSH"
  type        = list(string)
  default     = ["10.0.0.0/8"] # Solo redes privadas por defecto
}
