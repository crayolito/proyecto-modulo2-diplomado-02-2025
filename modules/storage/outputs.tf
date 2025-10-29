output "bucket_name" {
  description = "Nombre del bucket S3"
  value       = aws_s3_bucket.main.bucket
}

output "bucket_arn" {
  description = "ARN del bucket S3"
  value       = aws_s3_bucket.main.arn
}


# Generar par de claves SSH
# ssh-keygen -t rsa -b 4096 -f iac-key -C "iac-project"

# Esto crea:
# iac-key (clave privada)
# iac-key.pub (clave pública)
