# Bloque de Terraform -> Configuracion del motor
terraform {
  # Solo funciona con Terraform 1.0 o superior
  required_version = ">= 1.0"

  # Estos son los plugins que necesito
  required_providers {
    aws = {
      # Descargar el plugin oficial de AWS desde la web de Hashicorp
      source = "hashicorp/aws"
      # (~>) significa "compatible con la version 5.0 o superior"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}


# Modulo Network -> Llamando al codigo que hace el trabajo
# Los modulos son como funciones que se pueden reutilizar en diferentes proyectos.

module "network" {
  # El codigo de modulo esta en la carpeta modules/network
  source = "../../modules/network"
  # Variables que le paso al modulo
  nombre_proyecto = var.project_name
  # Ambiente del proyecto
  environment = var.environment
}


# Locals -> Variables locales del archivo
# Son variables (temporales) que solo existe en este archivo  
locals {
  # path.module -> Directorio actual del archivo
  # iac-key.pub -> Archivo de la clave publica
  public_key = file("${path.module}/iac-key.pub")
}

# Modulo Compute -> Crear el servidor
# Llama al modulo que crea el servidore EC2
# Le pasa toda la informacion que necesita
# Se le pasa el security group por defecto
module "compute" {
  source = "../../modules/compute"

  project_name          = var.project_name
  environment           = var.environment
  vpc_id                = module.network.vpc_id
  subnet_id             = module.network.public_subnet_id
  public_key            = local.public_key
  security_group_ids    = [module.security.secure_security_group_id]
  instance_profile_name = module.security.instance_profile_name
}

# Modulo Storage -> Crear el almacenamiento
# Llama al modulo que crea S3 Buckets se le pasa la informacion basica
# S3 no necesita (VPC, Subnet, etc.)
# Es un servicio global, no depende de tu VPC

module "storage" {
  source       = "../../modules/storage"
  project_name = var.project_name
  environment  = var.environment
}

# Módulo de seguridad
module "security" {
  source = "../../modules/security"

  project_name      = var.project_name
  environment       = var.environment
  vpc_id            = module.network.vpc_id
  vpc_cidr          = module.network.vpc_cidr_block
  bucket_arn        = module.storage.bucket_arn
  allowed_ssh_cidrs = ["10.0.0.0/16"] # Solo desde la VPC
}

# Módulo de secretos
module "secrets" {
  source = "../../modules/secrets"

  project_name = var.project_name
  environment  = var.environment
}




# ```
# ┌─────────────┐    vpc_id     ┌─────────────┐
# │   network   │──────────────▶│   compute   │
# │   module    │   subnet_id   │   module    │
# └─────────────┘               └─────────────┘
#                                      │
# ┌─────────────┐                      │
# │   storage   │                      │ Servidor
# │   module    │                      │ puede usar
# └─────────────┘                      │ S3 bucket
#       │                              │
#       └──────────────────────────────┘
# ```

# **FLUJO DE DEPENDENCIAS:**
# 1. **Network** crea VPC y subredes
# 2. **Compute** usa la VPC/subredes de Network
# 3. **Storage** se crea independientemente
# 4. El servidor puede usar el bucket S3
