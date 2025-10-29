# IaC Security Project

## Descripción

Proyecto de infraestructura como código con enfoque en seguridad

## Estructura

- `modules/` - Módulos reutilizables de Terraform
- `environments/` - Configuraciones por ambiente
- `scripts/` - Scripts de automatización

## Requisitos

- Terraform >= 1.0
- AWS CLI configurado
- Git

## Uso

```bash
cd environments/dev
terraform init
terraform plan
terraform apply
```

**📁 `.gitignore`**

```
# Terraform
*.tfstate
*.tfstate.*
.terraform/
.terraform.lock.hcl
crash.log
*.tfvars
*.tfvars.json

# Secrets
*.pem
*.key
.env

# OS
.DS_Store
Thumbs.db
```

---

## ✅ **Checkpoint Fase 1**

Ejecuta estos comandos para verificar que todo está listo:

```bash
# Verificar estructura
tree iac-security-project
# o si no tienes tree:
dir /s

# Inicializar Git
git init
git add .
git commit -m "Initial project structure"
```

**¿Todo funciona correctamente?** Si sí, ¡pasamos a la **Fase 2: Infraestructura base (Red)**!

¿Algún error o duda hasta aquí? 🤔
