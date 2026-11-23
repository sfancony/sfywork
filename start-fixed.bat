@echo off
setlocal
cd /d "%~dp0"

if not exist "certs\sfy-local.pfx" (
  echo A gerar certificado HTTPS local...
  powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\generate-cert.ps1" >nul
)

if not exist "certs\tunnel-config.yml" (
  echo.
  echo Ainda nao existe um túnel fixo configurado.
  echo.
  echo Para criar um link fixo e necessario um dominio proprio
  echo ^(ex.: sfy.seudominio.com^) e uma conta Cloudflare gratuita.
  echo.
  set /p Dominio="Introduza o dominio (ex.: sfy.exemplo.com): "
  powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\setup-fixed-link.ps1" -Domain "%Dominio%"
  if errorlevel 1 pause
)

echo.
echo  A iniciar SFY + túnel fixo...
echo.

start "SFY Servidor" cmd /c node "%~dp0src\server.js"
tools\cloudflared.exe tunnel --no-autoupdate --config "certs\tunnel-config.yml" run sfy

pause
