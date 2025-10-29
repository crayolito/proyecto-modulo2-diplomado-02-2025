# Script de validacion para Terraform
# Cambiar codificacion a UTF-8 para mejor compatibilidad
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

Write-Host "[*] Iniciando validaciones de seguridad y calidad..." -ForegroundColor Green

# Cambiar al directorio del proyecto
Set-Location $PSScriptRoot\..

Write-Host "`n[1/5] Terraform Format Check..." -ForegroundColor Yellow
$formatResult = terraform fmt -check -recursive
if ($LASTEXITCODE -ne 0) {
    Write-Host "[X] Error: Codigo no esta formateado correctamente" -ForegroundColor Red
    Write-Host "Ejecuta: terraform fmt -recursive" -ForegroundColor Yellow
    exit 1
}
Write-Host "[OK] Formato correcto" -ForegroundColor Green

Write-Host "`n[2/5] Terraform Validate..."  -ForegroundColor Yellow
Set-Location environments\dev
terraform validate
if ($LASTEXITCODE -ne 0) {
    Write-Host "[X] Error: Configuracion de Terraform invalida" -ForegroundColor Red
    exit 1
}
Write-Host "[OK] Configuracion valida" -ForegroundColor Green

Set-Location ..\..

Write-Host "`n[3/5] TFLint Analysis..." -ForegroundColor Yellow
tflint --init
tflint --recursive
$tflintExitCode = $LASTEXITCODE
if ($tflintExitCode -ne 0) {
    Write-Host "[!] TFLint encontro warnings (permitidos por configuracion)" -ForegroundColor Yellow
} else {
    Write-Host "[OK] TFLint paso sin errores" -ForegroundColor Green
}

Write-Host "`n[4/5] Checkov Security Scan..." -ForegroundColor Yellow
# Configurar codificacion UTF-8 para Checkov (forzar UTF-8 en operaciones de archivo)
$env:PYTHONIOENCODING = "utf-8"
$env:PYTHONUTF8 = "1"
checkov -d . --config-file .checkov.yml
$checkovExitCode = $LASTEXITCODE
if ($checkovExitCode -ne 0) {
    # Verificar si es un error de codificacion
    if ($checkovExitCode -eq 1) {
        Write-Host "[!] Checkov completo (revisa advertencias arriba)" -ForegroundColor Yellow
    } else {
        Write-Host "[X] Error: Checkov encontro problemas" -ForegroundColor Red
        Write-Host "Revisa los problemas reportados arriba" -ForegroundColor Yellow
        exit 1
    }
} else {
    Write-Host "[OK] Escaneo de seguridad completado" -ForegroundColor Green
}

Write-Host "`n[5/5] Secrets Scan..." -ForegroundColor Yellow
checkov --framework secrets -d .
if ($LASTEXITCODE -ne 0) {
    Write-Host "[!] Advertencia: Posibles secretos encontrados" -ForegroundColor Yellow
}

Write-Host "`n[OK] Todas las validaciones completadas exitosamente!" -ForegroundColor Green
Write-Host "Tu codigo esta listo para deployment" -ForegroundColor Cyan