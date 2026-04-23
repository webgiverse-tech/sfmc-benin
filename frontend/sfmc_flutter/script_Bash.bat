#!/bin/bash

# Tableau associatif : nom du service -> packages npm
declare -A services=(
    ["gateway"]="express http-proxy-middleware jsonwebtoken cors dotenv"
    ["auth-service"]="express better-sqlite3 bcryptjs jsonwebtoken cors dotenv"
    ["user-service"]="express better-sqlite3 cors dotenv"
    ["product-service"]="express better-sqlite3 cors dotenv"
    ["inventory-service"]="express better-sqlite3 cors dotenv"
    ["order-service"]="express better-sqlite3 cors dotenv axios"
    ["production-service"]="express better-sqlite3 cors dotenv axios"
    ["billing-service"]="express better-sqlite3 cors dotenv"
    ["notif-service"]="express better-sqlite3 cors dotenv"
    ["reporting-service"]="express better-sqlite3 cors dotenv axios"
)

for service in "${!services[@]}"; do
    echo "Initialisation de $service ..."
    mkdir -p "$service"
    cd "$service"
    npm init -y
    npm install ${services[$service]}
    # Création d'un fichier .gitignore de base
    echo "node_modules/" > .gitignore
    echo "*.db" >> .gitignore
    echo ".env" >> .gitignore
    cd ..
done

echo "Tous les services sont initialisés."