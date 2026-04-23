cd ~/Desktop/FLUTTER/sfmc_benin/backend

cat > start-all.bat << 'EOF'
@echo off
echo Demarrage de tous les microservices SFMC Benin...
start "Gateway"            cmd /k "cd /d %~dp0gateway && node index.js"
start "Auth Service"       cmd /k "cd /d %~dp0auth-service && node index.js"
start "User Service"       cmd /k "cd /d %~dp0user-service && node index.js"
start "Product Service"    cmd /k "cd /d %~dp0product-service && node index.js"
start "Inventory Service"  cmd /k "cd /d %~dp0inventory-service && node index.js"
start "Order Service"      cmd /k "cd /d %~dp0order-service && node index.js"
start "Production Service" cmd /k "cd /d %~dp0production-service && node index.js"
start "Billing Service"    cmd /k "cd /d %~dp0billing-service && node index.js"
start "Notif Service"      cmd /k "cd /d %~dp0notif-service && node index.js"
start "Reporting Service"  cmd /k "cd /d %~dp0reporting-service && node index.js"
echo Tous les services demarrent !
echo API Gateway sur http://localhost:3000
pause
EOF