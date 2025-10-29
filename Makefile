.PHONY: help init plan apply validate format clean

help: ## Mostrar ayuda
	@echo "Comandos disponibles:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}'

init: ## Inicializar Terraform
	cd environments/dev && terraform init

validate: ## Ejecutar todas las validaciones
	./scripts/validate.ps1

format: ## Formatear código Terraform
	terraform fmt -recursive

plan: validate ## Crear plan de Terraform
	cd environments/dev && terraform plan

apply: validate ## Aplicar cambios de Terraform
	cd environments/dev && terraform apply

destroy: ## Destruir infraestructura
	cd environments/dev && terraform destroy

clean: ## Limpiar archivos temporales
	find . -name ".terraform" -type d -exec rm -rf {} +
	find . -name "*.tfstate*" -delete
	find . -name ".terraform.lock.hcl" -delete

security-scan: ## Solo escaneo de seguridad
	checkov -d . --config-file .checkov.yml

lint: ## Solo linting
	tflint --recursive
```

### **Paso 7: Actualizar .gitignore**

**📁 `.gitignore` (agregar estas líneas)**
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
secrets.txt

# Tools
.tflint.d/
.checkov.yml.bak

# OS
.DS_Store
Thumbs.db

# IDE
.vscode/
.idea/
*.swp
*.swo

# Scripts execution
*.log