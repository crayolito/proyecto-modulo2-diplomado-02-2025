#!/bin/bash
yum update -y
yum install -y httpd aws-cli

# Configurar CloudWatch agent
yum install -y amazon-cloudwatch-agent

# Iniciar servicios
systemctl start httpd
systemctl enable httpd

# Página web básica con información del servidor
cat > /var/www/html/index.html << EOF
<html>
<head>
    <title>${project_name} - ${environment}</title>
</head>
<body>
    <h1>Servidor Seguro ${project_name}</h1>
    <p>Ambiente: ${environment}</p>
    <p>Servidor configurado con mejores prácticas de seguridad</p>
    <ul>
        <li>IMDSv2 habilitado</li>
        <li>Volúmenes cifrados</li>
        <li>Security Groups restrictivos</li>
        <li>IAM roles con privilegios mínimos</li>
    </ul>
</body>
</html>
EOF

# Configurar logs
mkdir -p /var/log/app
chown apache:apache /var/log/app