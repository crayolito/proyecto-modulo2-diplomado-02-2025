# Buscador de AMI(Amazon Machine Image) - "Encontrar la imagen del sistema operativo"
data "aws_ami" "amazon_linux" {
  # Dame la ultima version de la AMI
  most_recent = true
  # Solo las oficiales de Amazon
  owners = ["amazon"]
  # Buscar solo las que coincidan con este patron
  filter {
    name = "name"
    # Amazon Linux 2, virtualizacion HVM, arquitectura 64-bit
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# Security Group -> "Las reglas de seguridad del servidor"
# Guardia de seguridad  -> Dice quien puede entrar y salir de la instancia EC2.
resource "aws_security_group" "ec2_sg" {
  name        = "${var.project_name}-ec2-sg"
  description = "Security group para la instancia EC2"
  vpc_id      = var.vpc_id

  # Reglas SSH (Puerto 22) -> Permite el acceso SSH a la instancia.
  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    # Despues -> Cambiar a Ips especificas 
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Reglas HTTP (Puerto 80) -> Permite el acceso HTTP a la instancia.
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Reglas Egress -> Trabajo que sale del servidor.
  # Significa mi servidor puede conectarse a cualquier lugar
  egress {
    from_port = 0
    to_port   = 0
    # Todos los protocolos
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project_name}-ec2-sg"
    Environment = var.environment
  }
}

# Key Pai para SSH -> Tu llave para entrar al servidor.
resource "aws_key_pair" "main" {
  key_name   = "${var.project_name}-key"
  public_key = var.public_key
  tags = {
    Name        = "${var.project_name}-key"
    Environment = var.environment
  }
}

# Instancia ED2 - El servidor real
# resource "aws_instance" "main" {
#   # Que sistema operativo va usar 
#   ami = data.aws_ami.amazon_linux.id
#   # Que tan potente sera el servidor
#   instance_type = var.instance_type
#   # Que llave usar para SSH
#   key_name = aws_key_pair.main.key_name
#   # En que subred ponerlo (publica o privada)
#   subnet_id = var.subnet_id
#   # Que reglas de seguridad aplicar
#   vpc_security_group_ids = [aws_security_group.ec2_sg.id]

#   # Configuracion de Metadatos (Seguridad)
#   # Habilitar IMDSv2 (Amazon Metadata Service Version 2)
#   metadata_options {
#     # Habilitar el endpoint HTTP
#     http_endpoint = "enabled"
#     # Requiere tokens para acceder a las metadata
#     http_tokens = "required"
#     # Limite de saltos para la respuesta HTTP
#     http_put_response_hop_limit = 1
#   }

#   # Script de Inicio (User Data)
#   user_data = <<-EOF
#       #!/bin/bash
#       # Actualizar el sistema operativo
#       yum update -y
#       # Instalar Apache (Servidor web)
#       yum install -y httpd
#       # Inicia Apache
#       systemctl start httpd
#       # Que Apache se inicie automaticamente
#       systemctl enable httpd
#       # Crear el archivo index.html con el nombre del servidor y el ambiente
#       echo "<h1>Servidor ${var.project_name} - ${var.environment}</h1>" > /var/www/html/index.html
#     EOF

#   tags = {
#     Name        = "${var.project_name}-instance"
#     Environment = var.environment
#     Type        = "WebServer"
#   }
# }

# Instancia EC2 con seguridad mejorada
resource "aws_instance" "main" {
  # Es la plantilla del sistema operativo que se va a usar.
  ami = data.aws_ami.amazon_linux.id
  # Tipo de instancia que se va a usar.
  instance_type = var.instance_type
  # Refencia al key pair  (par de claves SSH) para acceder al servidor.
  key_name = aws_key_pair.main.key_name
  # Es una subred dentro de la VPC donde se ubicara la instancia.
  subnet_id = var.subnet_id

  # Esta linea usa un operador ternario
  # Si var.security_group_ids no es null, usa los security groups especificados.
  # Si es null, usa el security group por defecto.
  vpc_security_group_ids = var.security_group_ids != null ? var.security_group_ids : [aws_security_group.ec2_sg.id]

  # Asigna el instance profile IAM a la instancia.
  # Esto perimte que la instancia acceda a otros servicios de AWS sin claves API hardcodeadas.
  iam_instance_profile = var.instance_profile_name

  # Configuracion de Metadatos (Seguridad)
  # Habilitar IMDSv2 (Amazon Metadata Service Version 2)
  metadata_options {
    # Habilitar el endpoint HTTP
    http_endpoint = "enabled"
    # Requiere tokens para acceder a las metadata
    http_tokens = "required"
    # Limite de saltos para la respuesta HTTP
    http_put_response_hop_limit = 1
    # Habilitar tags en las metadata
    instance_metadata_tags = "enabled"
  }

  # Habilitar el monitoreo de la instancia. CloudWatch detailed monitoring.
  monitoring = true

  # Habilitar el optimizacion de EBS (Elastic Block Store)
  # Permite que la instancia use el mejor rendimiento de EBS.
  ebs_optimized = true

  # Configura el volumen raiz de la instancia.
  root_block_device {
    # GP3 es la ultima generacions de volumnes SSD de AWS.
    volume_type = "gp3"
    # Tamaño del volumen en GB.
    volume_size = 20
    # Cifrar el volumen.
    encrypted = true

    tags = {
      Name        = "${var.project_name}-root-volume"
      Environment = var.environment
    }
  }

  # Es un scprit que se ejecuta cuando la instancia arranca por primera vez.
  # AWS requiere que el user_data sea base64encoded.
  # templatefile -> Permite usar variables en el script.
  user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    project_name = var.project_name
    environment  = var.environment
  }))

  tags = {
    Name        = "${var.project_name}-instance"
    Environment = var.environment
    Type        = "WebServer"
    Security    = "Enhanced"
  }
}
