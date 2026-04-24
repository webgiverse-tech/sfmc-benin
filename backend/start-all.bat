@echo off
setlocal enabledelayedexpansion
chcp 65001 >nul

echo ===========================================
echo   SFMC Benin - Demarrage de tous les services
echo ===========================================
echo.

:: Definir le repertoire racine du backend
set "ROOT=%~dp0"
set "JWT_SECRET=sfmc_benin_super_secret_jwt_2026_key"

:: ─── BUG FIX : Génération propre des .env sans espace parasite ───
:: On utilise un fichier temporaire pour écrire proprement

call :write_env "gateway" "PORT=3000" "JWT_SECRET=%JWT_SECRET%"
call :write_env "auth-service" "PORT=3001" "JWT_SECRET=%JWT_SECRET%" "JWT_EXPIRES_IN=7d" "DB_PATH=./auth.db"
call :write_env "user-service" "PORT=3002" "JWT_SECRET=%JWT_SECRET%" "DB_PATH=./users.db"
call :write_env "product-service" "PORT=3003" "JWT_SECRET=%JWT_SECRET%" "DB_PATH=./products.db"
call :write_env "inventory-service" "PORT=3004" "JWT_SECRET=%JWT_SECRET%" "DB_PATH=./inventory.db"
call :write_env "order-service" "PORT=3005" "JWT_SECRET=%JWT_SECRET%" "DB_PATH=./orders.db" "INVENTORY_SERVICE_URL=http://localhost:3004" "PRODUCT_SERVICE_URL=http://localhost:3003"
call :write_env "production-service" "PORT=3006" "JWT_SECRET=%JWT_SECRET%" "DB_PATH=./production.db" "INVENTORY_SERVICE_URL=http://localhost:3004"
call :write_env "billing-service" "PORT=3007" "JWT_SECRET=%JWT_SECRET%" "DB_PATH=./billing.db" "ORDER_SERVICE_URL=http://localhost:3005" "USER_SERVICE_URL=http://localhost:3002"
call :write_env "notif-service" "PORT=3008" "JWT_SECRET=%JWT_SECRET%" "DB_PATH=./notifications.db"
call :write_env "reporting-service" "PORT=3009" "JWT_SECRET=%JWT_SECRET%" "DB_PATH=./reporting.db" "INVENTORY_SERVICE_URL=http://localhost:3004" "ORDER_SERVICE_URL=http://localhost:3005" "PRODUCTION_SERVICE_URL=http://localhost:3006" "BILLING_SERVICE_URL=http://localhost:3007" "USER_SERVICE_URL=http://localhost:3002"

echo .env generes avec succes !
echo.

:: ─── Lancement des services dans l'ordre conseillé ───
start "Auth (3001)"       cmd /k "cd /d "%ROOT%auth-service" && node index.js"
timeout /t 3 /nobreak >nul

start "User (3002)"       cmd /k "cd /d "%ROOT%user-service" && node index.js"
start "Product (3003)"    cmd /k "cd /d "%ROOT%product-service" && node index.js"
start "Inventory (3004)"  cmd /k "cd /d "%ROOT%inventory-service" && node index.js"
timeout /t 2 /nobreak >nul

start "Order (3005)"      cmd /k "cd /d "%ROOT%order-service" && node index.js"
start "Production (3006)" cmd /k "cd /d "%ROOT%production-service" && node index.js"
start "Billing (3007)"    cmd /k "cd /d "%ROOT%billing-service" && node index.js"
start "Notif (3008)"      cmd /k "cd /d "%ROOT%notif-service" && node index.js"
start "Reporting (3009)"  cmd /k "cd /d "%ROOT%reporting-service" && node index.js"
timeout /t 3 /nobreak >nul

start "Gateway (3000)"    cmd /k "cd /d "%ROOT%gateway" && node index.js"

echo.
echo ✅ Tous les services sont lances !
echo 🌐 Testez avec : http://localhost:3000/health
echo.
pause
goto :eof

:: ─── Fonction d'écriture propre du .env ───────────────────────────────────────
:write_env
set "dir=%~1"
set "envfile=%ROOT%%dir%\.env"
:: Supprimer le fichier s'il existe
if exist "%envfile%" del "%envfile%"
:: Écrire chaque variable (shift pour ignorer le 1er arg = nom du dossier)
shift
:loop_env
if "%~1"=="" goto :eof
echo %~1>> "%envfile%"
shift
goto loop_env
