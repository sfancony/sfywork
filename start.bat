@echo off
setlocal
cd /d "%~dp0"

if exist "C:\Program Files\nodejs\node.exe" (
  set "SFY_NODE=C:\Program Files\nodejs\node.exe"
) else (
  set "SFY_NODE=node"
)

if not exist "certs\sfy-local.pfx" (
  echo.
  echo  A gerar certificado HTTPS local...
  powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\generate-cert.ps1" >nul
)

echo.
echo  A iniciar a SFY...
echo  Abre o navegador em https://localhost:3000
echo  Outros dispositivos na rede: use o IP deste PC na porta 3000
echo  Se o browser avisar sobre o certificado: Avancado -Continuar
echo.
start "" "https://localhost:3000"
"%SFY_NODE%" src\server.js

pause
