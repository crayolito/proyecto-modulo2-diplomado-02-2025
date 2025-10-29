# VPC Principal -> Mi barrio digital
# Virtual Private Cloud -> Red privada virtual
resource "aws_vpc" "main" {
  # Define cuantas Ips tendras
  cidr_block = var.vpc_cidr
  # Permite usar nombres como "servidor1.com" en vez de solo IPs.
  enable_dns_hostnames = true
  # Activa el sistema de nombres de dominio (DNS) para la VPC.
  enable_dns_support = true
  tags = {
    Name        = "${var.nombre_proyecto}-vpc"
    Environment = var.environment
    Project     = var.nombre_proyecto
  }
}

# Puerta principal del barrio digital
resource "aws_internet_gateway" "main" {
  # Permite que la red se conecte a Internet -> Se conecta a la VPC que se creo arriba.
  vpc_id = aws_vpc.main.id
  tags = {
    Name        = "${var.nombre_proyecto}-igw"
    Environment = var.environment
  }
}

# Tu zona con Internet (Subred Publica)
resource "aws_subnet" "public" {
  # Indicamos la VPC a la que pertenece la subred
  vpc_id = aws_vpc.main.id
  # Que rango de ips va a tener la subred
  cidr_block = var.public_ubner_cidr
  # En que datacenter va a estar la subred (us-east-1a)
  availability_zone = var.availability_zone
  # Si la subred es publica, se le asigna una IP publica al iniciar el servidor. 
  # Los servidores en la subred publica pueden acceder a Internet.
  map_public_ip_on_launch = true
  tags = {
    Name        = "${var.nombre_proyecto}-public-subnet"
    Type        = "Public"
    Environment = var.environment
  }
}

# Tu zona privada (Subred Privada) -> SIN ACCESO A INTERNET
# Perfecto para bases de datos, servidores internos, etc.
resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidr
  availability_zone = var.availability_zone
  tags = {
    Name        = "${var.nombre_proyecto}-private-subnet"
    Type        = "Private"
    Environment = var.environment
  }
}

# Tabla de rutas para la subred publica -> Tu "GPS de red"
# Esta tabla de rutas define como se debe comportar la red cuando un paquete llega a la subred publica.
# Es como un GPS que dice "para ir a internet, usa esta puerta"
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    # Significa "TODO LO QUE LLEGA A LA SUBRED PUBLICA, VA A INTERNET"
    cidr_block = "0.0.0.0/0"
    # Usa la puerta principal del barrio digital para llegar a internet.
    gateway_id = aws_internet_gateway.main.id
  }
  tags = {
    Name        = "${var.nombre_proyecto}-public-route-table"
    Environment = var.environment
  }
}

# Asociacion -> Conecta la subred publica con las reglas de como llegar a internet
# Es como decirle a la subred publica "tu tabla de rutas es la public-route-table"
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}
