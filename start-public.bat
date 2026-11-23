@echo off
setlocal
cd /d "%~dp0"

if not exist "certs\sfy-local.pfx" (
  echo A gerar certificado HTTPS local...
  powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\generate-cert.ps1" >nul
)

if not exist "tools\cloudflared.exe" (
  echo A descarregar o cloudflared...
  powershell -NoProfile -ExecutionPolicy Bypass -Command "New-Item -ItemType Directory -Force -Path 'tools' | Out-Null; Invoke-WebRequest -Uri 'https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-windows-amd64.exe' -OutFile 'tools\cloudflared.exe' -UseBasicParsing"
)

echo.
echo  A iniciar o servidor SFY e o tunel publico...
echo  O link publico aparece abaixo (trycloudflare.com).
echo  Partilha esse link com os utilizadores.
echo.

start "SFY Servidor" cmd /c node "%~dp0src\server.js"
tools\cloudflared.exe tunnel --no-autoupdate --no-tls-verify --url https://localhost:3000

pause
