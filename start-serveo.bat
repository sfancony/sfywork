@echo off
setlocal
cd /d "%~dp0"

if not exist "certs\sfy-local.pfx" (
  echo A gerar certificado HTTPS local...
  powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\generate-cert.ps1" >nul
)

if not exist "certs\serveo_ed25519" (
  echo A gerar chave SSH para o Serveo...
  ssh-keygen -t ed25519 -C "sfy-serveo" -f "%~dp0certs\serveo_ed25519" -N ""
)

echo.
echo  Link fixo (conta Serveo gratis): https://sfywork.serveo.net
echo.
echo  Primeira vez: abrir https://console.serveo.net, criar conta,
echo  adicionar a chave publica certs\serveo_ed25519.pub em Keys/SSH keys
echo  e reservar o hostname sfywork.serveo.net em Domains.
echo.
echo  Na primeira visita ao link publico pode aparecer um aviso do Serveo:
echo  basta clicar em "Continue" (tunnel gratuito).
echo.

set TUNNEL_PORT=3001

netstat -ano | findstr ":3001" | findstr "LISTENING" >nul
set PORTAL=%errorlevel%
netstat -ano | findstr ":3000" | findstr "LISTENING" >nul
set SERVER=%errorlevel%

if "%PORTAL%"=="0" (
  echo Servidor SFY e portal do tunel ja estao ativos.
) else (
  if "%SERVER%"=="0" (
    echo AVISO: existe um SFY na porta 3000 sem portal do tunel na 3001.
    echo Encerra esse servidor e executa este script novamente.
    pause
    exit /b 1
  )
  start "SFY Servidor" cmd /c node "%~dp0src\server.js"
)

ssh -o ServerAliveInterval=30 -o ServerAliveCountMax=3 -o StrictHostKeyChecking=accept-new -i "%~dp0certs\serveo_ed25519" -R sfywork.serveo.net:80:127.0.0.1:3001 -- serveo.net --https-only

pause
