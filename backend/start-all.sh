#!/bin/bash

# Génération des .env (comme dans le .bat)
echo "Génération des fichiers .env …"
JWT_SECRET="sfmc_benin_super_secret_jwt_2026_key"

echo "PORT=3000" > gateway/.env
echo "JWT_SECRET=$JWT_SECRET" >> gateway/.env

echo "PORT=3001" > auth-service/.env
echo "JWT_SECRET=$JWT_SECRET" >> auth-service/.env
echo "JWT_EXPIRES_IN=7d" >> auth-service/.env
echo "DB_PATH=./auth.db" >> auth-service/.env

echo "PORT=3002" > user-service/.env
echo "JWT_SECRET=$JWT_SECRET" >> user-service/.env
echo "DB_PATH=./users.db" >> user-service/.env

echo "PORT=3003" > product-service/.env
echo "JWT_SECRET=$JWT_SECRET" >> product-service/.env
echo "DB_PATH=./products.db" >> product-service/.env

echo "PORT=3004" > inventory-service/.env
echo "JWT_SECRET=$JWT_SECRET" >> inventory-service/.env
echo "DB_PATH=./inventory.db" >> inventory-service/.env

echo "PORT=3005" > order-service/.env
echo "JWT_SECRET=$JWT_SECRET" >> order-service/.env
echo "DB_PATH=./orders.db" >> order-service/.env
echo "INVENTORY_SERVICE_URL=http://localhost:3004" >> order-service/.env
echo "PRODUCT_SERVICE_URL=http://localhost:3003" >> order-service/.env

echo "PORT=3006" > production-service/.env
echo "JWT_SECRET=$JWT_SECRET" >> production-service/.env
echo "DB_PATH=./production.db" >> production-service/.env
echo "INVENTORY_SERVICE_URL=http://localhost:3004" >> production-service/.env

echo "PORT=3007" > billing-service/.env
echo "JWT_SECRET=$JWT_SECRET" >> billing-service/.env
echo "DB_PATH=./billing.db" >> billing-service/.env
echo "ORDER_SERVICE_URL=http://localhost:3005" >> billing-service/.env
echo "USER_SERVICE_URL=http://localhost:3002" >> billing-service/.env

echo "PORT=3008" > notif-service/.env
echo "JWT_SECRET=$JWT_SECRET" >> notif-service/.env
echo "DB_PATH=./notifications.db" >> notif-service/.env

echo "PORT=3009" > reporting-service/.env
echo "JWT_SECRET=$JWT_SECRET" >> reporting-service/.env
echo "INVENTORY_SERVICE_URL=http://localhost:3004" >> reporting-service/.env
echo "ORDER_SERVICE_URL=http://localhost:3005" >> reporting-service/.env
echo "PRODUCTION_SERVICE_URL=http://localhost:3006" >> reporting-service/.env
echo "BILLING_SERVICE_URL=http://localhost:3007" >> reporting-service/.env
echo "USER_SERVICE_URL=http://localhost:3002" >> reporting-service/.env

echo "✅ .env générés."

echo "Démarrage des services …"

# Tableau associatif des services (nom de dossier -> titre)
declare -A services=(
  ["auth-service"]="Auth (3001)"
  ["user-service"]="User (3002)"
  ["product-service"]="Product (3003)"
  ["inventory-service"]="Inventory (3004)"
  ["order-service"]="Order (3005)"
  ["production-service"]="Production (3006)"
  ["billing-service"]="Billing (3007)"
  ["notif-service"]="Notif (3008)"
  ["reporting-service"]="Reporting (3009)"
  ["gateway"]="Gateway (3000)"
)

for folder in "${!services[@]}"; do
  title="${services[$folder]}"
  echo "  ➤ $title"
  (cd "$folder" && node index.js) &
  sleep 1
done

echo ""
echo "✅ Tous les services sont lancés en arrière-plan."
echo "   Gateway → http://localhost:3000"
echo "   Auth    → http://localhost:3001"
echo ""
echo "⚠️  Pour arrêter tous les services, tapez : kill %1 %2 %3 … (ou fermez le terminal)."

# Maintenir le terminal ouvert
wait
