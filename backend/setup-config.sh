#!/bin/bash

# Définition des ports pour chaque service (pour éviter les conflits)
declare -A ports=(
    ["gateway"]="4000"
    ["auth-service"]="4001"
    ["user-service"]="4002"
    ["product-service"]="4003"
    ["inventory-service"]="4004"
    ["order-service"]="4005"
    ["production-service"]="4006"
    ["billing-service"]="4007"
    ["notif-service"]="4008"
    ["reporting-service"]="4009"
)

# Clé secrète JWT commune (à changer en production)
JWT_SECRET="super_secret_jwt_key_change_me_in_prod"

for service in "${!ports[@]}"; do
    echo "Configuration de $service..."

    cd "$service" || continue

    # --- 1. Mise à jour du package.json pour ajouter les scripts "start" et "dev" ---
    # Vérifie si le script "start" existe déjà
    if ! grep -q '"start"' package.json; then
        # Utilisation de sed pour insérer les scripts après la ligne "scripts": {
        sed -i '/"scripts": {/a \    "start": "node index.js",\n    "dev": "nodemon index.js",' package.json
        echo "  -> Scripts 'start' et 'dev' ajoutés."
    else
        echo "  -> Les scripts existent déjà."
    fi

    # --- 2. Création du fichier .env avec variables par défaut ---
    cat > .env <<EOF
PORT=${ports[$service]}
JWT_SECRET=$JWT_SECRET
DB_PATH=./${service}.db
EOF
    echo "  -> Fichier .env créé (PORT=${ports[$service]}, DB=${service}.db)."

    # --- 3. Installation de nodemon en dépendance de développement ---
    npm install --save-dev nodemon
    echo "  -> nodemon installé en dev."

    # --- 4. Vérification/Création du .gitignore (si ce n'est pas déjà fait) ---
    if [ ! -f .gitignore ]; then
        echo "node_modules/" > .gitignore
        echo "*.db" >> .gitignore
        echo ".env" >> .gitignore
        echo "  -> .gitignore créé."
    else
        # Ajoute les lignes manquantes si elles n'y sont pas déjà
        grep -qxF "node_modules/" .gitignore || echo "node_modules/" >> .gitignore
        grep -qxF "*.db" .gitignore || echo "*.db" >> .gitignore
        grep -qxF ".env" .gitignore || echo ".env" >> .gitignore
        echo "  -> .gitignore mis à jour."
    fi

    cd ..
done

echo "Configuration terminée pour tous les services."