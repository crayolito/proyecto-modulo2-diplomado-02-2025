# S3 Bucket Principal -> Crear un almacen
resource "aws_s3_bucket" "main" {
  # ${var.project_name}-${var.environment}-${random_string.bucket_suffix.result}
  # │                   │                   │
  # │                   │                   └── Texto aleatorio (ej: "a1b2c3d4")
  # │                   └────────────────────── Ambiente (ej: "dev", "prod")
  # └────────────────────────────────────────── Nombre proyecto (ej: "miapp")
  # Nombre del bucket = "miapp-dev-a1b2c3d4"
  bucket = "${var.project_name}-${var.environment}-${random_string.bucket_suffix.result}"
  tags = {
    Name        = "${var.project_name}-bucket"
    Environment = var.environment
  }
}

# Sufijo Aletorio - Evitar nombres duplicados
# Para que no se repitan los nombres de los buckets
resource "random_string" "bucket_suffix" {
  length  = 8
  special = false
  upper   = false
}

# Versionado -> Historial de cambios
# - Guarda multiples versiones del mismo archivo
# - Como el historial de versiones  de Google Docs
# Es como tener un Ctrl+Z para cada cambio.
resource "aws_s3_bucket_versioning" "main" {
  bucket = aws_s3_bucket.main.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Cifrado - "Seguridad de los datos"
# Codifica tus archivos para que solo tu puedas verlos, aunque roben el disco AWS.
# server_side_encryption -> El cifrado lo hace AWS automaticamente.
resource "aws_s3_bucket_server_side_encryption_configuration" "main" {

  bucket = aws_s3_bucket.main.id
  rule {
    # Cifra TODO lo que subas
    apply_server_side_encryption_by_default {
      # Algoritmo de cifrado -> AES256 es el mas fuerte
      sse_algorithm = "AES256"
    }
  }
}

# Bloque de Acceso Publico - "Cerrar todas las puertas"
resource "aws_s3_bucket_public_access_block" "main" {
  bucket = aws_s3_bucket.main.id
  # Bloquea el acceso publico a los archivos ACL (lista  de quien puede acceder)
  block_public_acls = true
  # Bloquea que puedas crear polticas que hagan el bucket publico
  block_public_policy = true
  # Ignora cualquier ACL publica que ya existe
  ignore_public_acls = true
  # Restringe el acceso incluso si hay politicas publicas (Doble seguridad)
  restrict_public_buckets = true
}
