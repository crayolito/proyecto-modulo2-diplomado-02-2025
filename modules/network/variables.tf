variable "nombre_proyecto" {
  description = "Nombre del proyecto"
  type        = string
}

variable "environment" {
  description = "Ambiente  (dev, prod, etc.)"
  type        = string
}


# CIDR = Classless Inter-Domain Routing (Un sistema para repartir direcciones IP de manera inteligente)
# Es una forma de decir cuantas direcciones IP tienes disponibles en tu red
# Es como decirle AWS reserva este rango de direcciones IP para mi red y organizalas asi.
variable "vpc_cidr" {
  description = "CIDR block para la VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_ubner_cidr" {
  description = "CIDR block para la subred pública"
  type        = string
  default     = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
  description = "CIDR block para la subred privada"
  type        = string
  default     = "10.0.2.0/24"
}

variable "availability_zone" {
  description = "Availability zone para la subred"
  type        = string
  default     = "us-east-1a"
}
