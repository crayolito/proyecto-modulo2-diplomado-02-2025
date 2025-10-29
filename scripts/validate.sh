#!/bin/bash

echo "🔍 Iniciando validaciones de seguridad y calidad..."

# Cambiar al directorio del proyecto
cd "$(dirname "$0")/.."

echo ""
echo "📋 1. Terraform Format Check..."
if ! terraform fmt -check -recursive; then
    echo "❌ Error: Código no está formateado correctamente"
    echo "Ejecuta: terraform fmt -recursive"
    exit 1
fi
echo "✅ Formato correcto"

echo ""
echo "🔧 2. Terraform Validate..."
cd environments/dev
if ! terraform validate; then
    echo "❌ Error: Configuración de Terraform inválida"
    exit 1
fi
echo "✅ Configuración válida"
cd ../..

echo ""
echo "🔍 3. TFLint Analysis..."
tflint --init
if ! tflint --recursive; then
    echo "❌ Error: TFLint encontró problemas"
    exit 1
fi
echo "✅ TFLint pasó sin errores"

echo ""
echo "🛡️ 4. Checkov Security Scan..."
if ! checkov -d . --config-file .checkov.yml; then
    echo "❌ Error: Checkov encontró problemas de seguridad"
    echo "Revisa los problemas reportados arriba"
    exit 1
fi
echo "✅ Escaneo de seguridad completado"

echo ""
echo "🔐 5. Secrets Scan..."
checkov --framework secrets -d .

echo ""
echo "🎉 Todas las validaciones completadas exitosamente!"
echo "Tu código está listo para deployment 🚀"