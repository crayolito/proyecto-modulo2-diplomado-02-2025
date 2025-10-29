# AWS Secrets Manager -> Gestiona secretos como contraseñas, claves API, tokens, etc.
resource "aws_secretsmanager_secret" "db_credentials" {
  name        = "${var.project_name}-db-credentials"
  description = "Credenciales de la base de datos"
  # Ventana de recuperacion -> Si el secreto se elimina, se puede recuperar en los ultimos 7 dias.
  recovery_window_in_days = 7
  tags = {
    Name        = "${var.project_name}-db-credentials"
    Environment = var.environment
  }
}

# Version del secreto con credenciales generadas
# Crea una VERSION del secreto, AWS pueden tener multiples versiones de un secreto.
resource "aws_secretsmanager_secret_version" "db_credentials" {
  # Conecta esta version con el secreto creado en el sector anterior.
  secret_id = aws_secretsmanager_secret.db_credentials.id
  # El contenido real del secreto en formato JSON.
  secret_string = jsonencode({
    # El nombre de usaurio de una variable de Terraform.
    username = var.db_username
    # Genera una contraseña aleatoria con Terraform.
    password = random_password.db_password.result
  })
}

# Password Generado Aletoriamente
# Usa el provider "random" de Terraform para generar una contraseña aleatoria.
resource "random_password" "db_password" {
  # Longitud de la contraseña.
  length = 16
  # No incluye caracteres especiales.
  special = false
}

# Parameter Store para configuraciones no sensibles
# Crea un parametro en AWS Systems Manager Parameter Store.
# Que es un servicio para almacenar configuraciones no sensibles.
resource "aws_ssm_parameter" "app_config" {
  # Nombre jerarquico del parametro usando (slashes) 
  name = "/${var.project_name}/${var.environment}/app-config"
  type = "String"
  # jsonencode -> Convierte un objeto de Terraform en JSON string.
  value = jsonencode({
    # Nivel de logging de la app (INFO, DEBUG, ERROR, etc.)
    log_level = "INFO"
    # Maximo de conexiones a la base de datos.
    max_connections = "100"
    # Timeout de la conexion a la base de datos.
    timeout = "30"
  })
  tags = {
    Name        = "${var.project_name}-app-config"
    Environment = var.environment
  }
}
