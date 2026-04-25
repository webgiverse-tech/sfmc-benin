@echo off
setlocal enabledelayedexpansion
chcp 65001 >nul

echo =====================================================
echo   SFMC Benin ^| Demarrage de tous les microservices
echo =====================================================
echo.

set "ROOT=%~dp0"
set "JWT=sfmc_benin_super_secret_jwt_2026_key"

echo [1/2] Generation des fichiers .env...

:: Ecriture propre sans espaces parasites
(echo PORT=3000&echo JWT_SECRET=%JWT%) > "%ROOT%gateway\.env"
(echo PORT=3001&echo JWT_SECRET=%JWT%&echo JWT_EXPIRES_IN=7d&echo DB_PATH=./auth.db) > "%ROOT%auth-service\.env"
(echo PORT=3002&echo JWT_SECRET=%JWT%&echo DB_PATH=./users.db) > "%ROOT%user-service\.env"
(echo PORT=3003&echo JWT_SECRET=%JWT%&echo DB_PATH=./products.db) > "%ROOT%product-service\.env"
(echo PORT=3004&echo JWT_SECRET=%JWT%&echo DB_PATH=./inventory.db) > "%ROOT%inventory-service\.env"
(echo PORT=3005&echo JWT_SECRET=%JWT%&echo DB_PATH=./orders.db&echo INVENTORY_SERVICE_URL=http://localhost:3004&echo PRODUCT_SERVICE_URL=http://localhost:3003) > "%ROOT%order-service\.env"
(echo PORT=3006&echo JWT_SECRET=%JWT%&echo DB_PATH=./production.db&echo INVENTORY_SERVICE_URL=http://localhost:3004) > "%ROOT%production-service\.env"
(echo PORT=3007&echo JWT_SECRET=%JWT%&echo DB_PATH=./billing.db&echo ORDER_SERVICE_URL=http://localhost:3005&echo USER_SERVICE_URL=http://localhost:3002) > "%ROOT%billing-service\.env"
(echo PORT=3008&echo JWT_SECRET=%JWT%&echo DB_PATH=./notifications.db) > "%ROOT%notif-service\.env"
(echo PORT=3009&echo JWT_SECRET=%JWT%&echo DB_PATH=./reporting.db&echo INVENTORY_SERVICE_URL=http://localhost:3004&echo ORDER_SERVICE_URL=http://localhost:3005&echo PRODUCTION_SERVICE_URL=http://localhost:3006&echo BILLING_SERVICE_URL=http://localhost:3007&echo USER_SERVICE_URL=http://localhost:3002) > "%ROOT%reporting-service\.env"

echo    OK - .env generes pour tous les services
echo.
echo [2/2] Demarrage des services...
echo.

:: Ordre : Data services d'abord, Gateway en dernier
start "Auth     :3001" cmd /k "cd /d "%ROOT%auth-service"       && node index.js"
timeout /t 4 /nobreak >nul

start "Users    :3002" cmd /k "cd /d "%ROOT%user-service"       && node index.js"
start "Products :3003" cmd /k "cd /d "%ROOT%product-service"    && node index.js"
start "Inventory:3004" cmd /k "cd /d "%ROOT%inventory-service"  && node index.js"
timeout /t 3 /nobreak >nul

start "Orders   :3005" cmd /k "cd /d "%ROOT%order-service"      && node index.js"
start "Prod     :3006" cmd /k "cd /d "%ROOT%production-service" && node index.js"
start "Billing  :3007" cmd /k "cd /d "%ROOT%billing-service"    && node index.js"
start "Notif    :3008" cmd /k "cd /d "%ROOT%notif-service"      && node index.js"
start "Reporting:3009" cmd /k "cd /d "%ROOT%reporting-service"  && node index.js"
timeout /t 4 /nobreak >nul

:: Gateway EN DERNIER (doit trouver tous les services deja up)
start "Gateway  :3000" cmd /k "cd /d "%ROOT%gateway"            && node index.js"

echo.
echo =====================================================
echo   TOUS LES SERVICES SONT LANCES !
echo =====================================================
echo.
echo   Health check : http://localhost:3000/health
echo   Login test   : POST http://localhost:3000/api/auth/login
echo.
echo   Identifiants :
echo     admin@sfmc.bj    / admin123
echo     operateur@sfmc.bj / oper123
echo     client@sfmc.bj   / client123
echo.
pause
