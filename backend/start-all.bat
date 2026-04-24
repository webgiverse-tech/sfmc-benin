@echo off
setlocal enabledelayedexpansion

echo ===========================================
echo   SFMC Benin – Demarrage de tous les services
echo ===========================================
echo.

:: Generation des .env
set JWT_SECRET=sfmc_benin_super_secret_jwt_2026_key

echo PORT=3000 > gateway\.env
echo JWT_SECRET=%JWT_SECRET% >> gateway\.env

echo PORT=3001 > auth-service\.env
echo JWT_SECRET=%JWT_SECRET% >> auth-service\.env
echo JWT_EXPIRES_IN=7d >> auth-service\.env
echo DB_PATH=./auth.db >> auth-service\.env

echo PORT=3002 > user-service\.env
echo JWT_SECRET=%JWT_SECRET% >> user-service\.env
echo DB_PATH=./users.db >> user-service\.env

echo PORT=3003 > product-service\.env
echo JWT_SECRET=%JWT_SECRET% >> product-service\.env
echo DB_PATH=./products.db >> product-service\.env

echo PORT=3004 > inventory-service\.env
echo JWT_SECRET=%JWT_SECRET% >> inventory-service\.env
echo DB_PATH=./inventory.db >> inventory-service\.env

echo PORT=3005 > order-service\.env
echo JWT_SECRET=%JWT_SECRET% >> order-service\.env
echo DB_PATH=./orders.db >> order-service\.env
echo INVENTORY_SERVICE_URL=http://localhost:3004 >> order-service\.env
echo PRODUCT_SERVICE_URL=http://localhost:3003 >> order-service\.env

echo PORT=3006 > production-service\.env
echo JWT_SECRET=%JWT_SECRET% >> production-service\.env
echo DB_PATH=./production.db >> production-service\.env
echo INVENTORY_SERVICE_URL=http://localhost:3004 >> production-service\.env

echo PORT=3007 > billing-service\.env
echo JWT_SECRET=%JWT_SECRET% >> billing-service\.env
echo DB_PATH=./billing.db >> billing-service\.env
echo ORDER_SERVICE_URL=http://localhost:3005 >> billing-service\.env
echo USER_SERVICE_URL=http://localhost:3002 >> billing-service\.env

echo PORT=3008 > notif-service\.env
echo JWT_SECRET=%JWT_SECRET% >> notif-service\.env
echo DB_PATH=./notifications.db >> notif-service\.env

echo PORT=3009 > reporting-service\.env
echo JWT_SECRET=%JWT_SECRET% >> reporting-service\.env
echo INVENTORY_SERVICE_URL=http://localhost:3004 >> reporting-service\.env
echo ORDER_SERVICE_URL=http://localhost:3005 >> reporting-service\.env
echo PRODUCTION_SERVICE_URL=http://localhost:3006 >> reporting-service\.env
echo BILLING_SERVICE_URL=http://localhost:3007 >> reporting-service\.env
echo USER_SERVICE_URL=http://localhost:3002 >> reporting-service\.env

echo .env generes avec succes.

:: Lancement des services (ordre tolerant)
start "Auth (3001)"       cmd /k "cd /d "%~dp0auth-service" && node index.js && pause"
timeout /t 2 /nobreak >nul
start "User (3002)"       cmd /k "cd /d "%~dp0user-service" && node index.js && pause"
start "Product (3003)"    cmd /k "cd /d "%~dp0product-service" && node index.js && pause"
start "Inventory (3004)"  cmd /k "cd /d "%~dp0inventory-service" && node index.js && pause"
start "Order (3005)"      cmd /k "cd /d "%~dp0order-service" && node index.js && pause"
start "Production (3006)" cmd /k "cd /d "%~dp0production-service" && node index.js && pause"
start "Billing (3007)"    cmd /k "cd /d "%~dp0billing-service" && node index.js && pause"
start "Notif (3008)"      cmd /k "cd /d "%~dp0notif-service" && node index.js && pause"
start "Reporting (3009)"  cmd /k "cd /d "%~dp0reporting-service" && node index.js && pause"
start "Gateway (3000)"    cmd /k "cd /d "%~dp0gateway" && node index.js && pause"

echo.
echo Tous les services sont lances !
echo Testez avec http://localhost:3000/health
pause
exit