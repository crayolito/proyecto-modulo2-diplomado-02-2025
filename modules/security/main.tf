# ROL IAM PARA LA INSTANCIA EC2
# IAM -> Es el sistema de AWS para gestionar permisos y accesos
# Es la base de seguridad que permite que las instancias EC2 se conecten a otros servicios de AWS.
# Es obligatorio si quieres que el EC2 acceda a otros servicios de AWS. Sin esto se usara claves API hardcodeadas.
resource "aws_iam_role" "ec2_role" {
  name = "${var.project_name}-ec2-role"

  # Define la  politica de asuncion del rol es un politica 
  # especifica QUIEN puede asumir este rol.
  # jsonencode -> Convierte el objeto de Terraform en JSON.
  assume_role_policy = jsonencode({
    # Version de la politica
    Version = "2012-10-17"
    # Cada declaracion es una regla que define QUIEN puede asumir este rol.
    Statement = [

      {
        # STS -> significa Security Token Service -> Servicio de Seguridad de Tokens
        Action = "sts:AssumeRole"
        # Allow -> Permite la asuncion del rol
        Effect = "Allow"
        # Principal -> Define el servicio que puede asumir el rol.
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "${var.project_name}-ec2-role"
    Environment = var.environment
  }
}

# POLITICA IAM CON PRIVILEGIOS MINIMOS -> Solo permite lo necesario para el EC2.
# Es una lista de permisos de loq ue puedes hacer
resource "aws_iam_policy" "ec2_policy" {
  name        = "${var.project_name}-ec2-policy"
  description = "Politica con permisos minimos para el EC2"
  # jsonencode -> Convierte un objeto de Terraform en JSON string.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        # Allow -> Permite la siguientes acciones
        Effect = "Allow"
        # S3 es el servicio de almacenamiento de AWS
        # GetObject -> Descarga un archivo
        # PutObject -> Sube un archivo
        Action = ["s3:GetObject", "s3:PutObject"]
        # ARN -> Amazon Resource Name -> Identificador unico para un recurso en AWS.
        # * -> Todos los archivos del bucket
        Resource = "${var.bucket_arn}/*"
      },
      {
        Effect = "Allow"
        # ListBucket -> Permite ver la lista de archivos del bucket.
        Action   = ["s3:ListBucket"]
        Resource = var.bucket_arn
      },
      {
        # Permisos para CloudWatch Logs, es el servicio de AWS
        # para almacenar logs. Permite crear grupos, streams y eventos.
        Effect = "Allow"
        Action = [
          # 
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        # Los asteriscos (*) son wildcards -> Permiten que cualquier valor que se pase
        # region, cuenta o recurso de logs
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })

  tags = {
    Name        = "${var.project_name}-ec2-policy"
    Environment = var.environment
  }
}


# ADJUNTAR POLITICA AL ROL
# Este recurso CONECTA una politica con un rol. Es como pegar los permisos en el rol.
# Es como un firewall  virtual que ocntrola que trafico puede entrar y salir de las instancias EC2.
resource "aws_iam_role_policy_attachment" "ec2_policy_attachment" {
  # Role -> El rol que queremos adjuntar la politica.
  role = aws_iam_role.ec2_role.name
  # Policy -> La politica que queremos adjuntar al rol.
  policy_arn = aws_iam_policy.ec2_policy.arn
}

# INSTANCE PROFILE PARA EC2
# Crea un INSTANCE PROFILE para EC2. Es como un adaptador entre EC2 y el rol IAM.
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.project_name}-ec2-profile"
  role = aws_iam_role.ec2_role.name

  tags = {
    Name        = "${var.project_name}-ec2-profile"
    Environment = var.environment
  }
}

# SECURIY GROUP MEJORADO PARA EC2
resource "aws_security_group" "secure_ec2_sg" {
  name        = "${var.project_name}-secure-ec2-sg"
  description = "Security group para la instancia EC2"
  vpc_id      = var.vpc_id

  # SSH solo desde IPs especificas (NO 0.0.0.0/0)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_ssh_cidrs
    description = "SSH desde IPs especificas"
  }

  # HTTP solo desde la VPC (NO acceso publico) (Web no encriptadas)
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
    description = "HTTP desde la VPC"
  }

  # HTTPS solo desde la VPC (NO acceso publico) (Web encriptadas con SSL/TLS)
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
    description = "HTTPS desde la VPC"
  }

  # Trafico saliente solo necesario
  egress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    # Significa "toda internet" permite conectar a cualquier sitio web HTTP
    cidr_blocks = ["0.0.0.0/0"]
    description = "Trafico saliente HTTP"
  }

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Trafico saliente HTTPS"
  }

  # Sin DNS no puedes navegar a ningun sitio web.
  # No podra la instancia EC2 resolver nombres como "google.com" o "amazon.com"
  egress {
    from_port = 53
    to_port   = 53
    # UDP -> Protocolo de Datagramas de Usuario -> No necesita confirmacion de entrega.
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Trafico saliente DNS"
  }

  tags = {
    Name        = "${var.project_name}-secure-ec2-sg"
    Environment = var.environment
    Security    = "Restricted"
  }
}

# WAF PARA PROTEGER LA WEB
# Es un firewall especializado para aplicaciones web que analiza el contenido HTTP/HTTPS.
resource "aws_wafv2_web_acl" "main" {
  name = "${var.project_name}-waf-acl"
  # Define si el WAF es regional (REGIONAL) o global (CLOUDFRONT)
  # Regional -> Solo protege un solo dominio o subdominio.
  # Global -> Protege todos los dominios y subdominios de una cuenta AWS.
  scope = "REGIONAL"

  # Accion por defecto -> Permite todo el trafico que no coincide con las reglas.
  default_action {
    allow {}
  }

  # Define una regla especfica del WAF
  rule {
    # Esta es una regla administrada por AWS que protege contra ataques comunes.
    name = "AWSManagedRulesCommonRuleSet"
    # 1 = Mas alta prioridad, se ejecuta primero.
    priority = 1

    # No se aplica ninguna accion adicional a esta regla.
    override_action {
      none {}
    }

    # Define que esta regla usa un grupo de reglas administradas por AWS.
    statement {
      managed_rule_group_statement {
        # Cojunto de reglas que protege contra ataques comunes.
        # SQL Injection, Cross-Site Scripting (XSS), etc.
        # Cross-Site Scripting (XSS) -> Inyeccion de scripts maliciosos en la pagina web.
        # Path traversal -> Intentos de acceder a archivos del sistema
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }

    # Configuracion de monitorio
    # Configuracion de metricas y logs
    visibility_config {
      # Habilita metricas en CloudWatch (Servicios de monitoreo de AWS)
      cloudwatch_metrics_enabled = true
      # Nombre de la metrica para identificarla en CloudWatch
      metric_name = "CommonRuleSetMetric"
      # Habilita el muestreo de solicitudes para la metrica.
      sampled_requests_enabled = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${var.project_name}-waf-metric"
    sampled_requests_enabled   = true
  }

  tags = {
    Name        = "${var.project_name}-waf"
    Environment = var.environment
  }
}
