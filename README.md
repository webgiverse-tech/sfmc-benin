# 🏭 SFMC Bénin – Système de Gestion Industrielle

![version](https://img.shields.io/badge/version-1.0.0-blue)
![Node.js](https://img.shields.io/badge/Node.js-≥18-green)
![Flutter](https://img.shields.io/badge/Flutter-3.32.0+-blue)
![licence](https://img.shields.io/badge/licence-MIT-lightgrey)

**SFMC Bénin** est une application complète de gestion pour une entreprise de production et distribution de matériaux de construction (ciment, fer, briques, granulats).  
Elle est composée d’un **backend en microservices** (Node.js/Express + SQLite) et d’un **frontend moderne** développé avec **Flutter Web**.

---

## 📸 Aperçu

| Login | Tableau de bord | Gestion des stocks |
|-------|-----------------|--------------------|
| *(captures à venir)* | *(dashboard animé avec KPIs)* | *(alertes en temps réel)* |

---

## 🧱 Architecture
sfmc_benin/
├── backend/
│ ├── gateway/ (API Gateway port 3000)
│ ├── auth-service/ (Authentification JWT)
│ ├── user-service/ (Gestion des profils)
│ ├── product-service/ (Catalogue produits)
│ ├── inventory-service/ (Stocks & entrepôts)
│ ├── order-service/ (Commandes clients)
│ ├── production-service/ (Ordre de fabrication)
│ ├── billing-service/ (Factures & paiements)
│ ├── notif-service/ (Notifications)
│ └── reporting-service/ (KPIs & rapports)
└── frontend/
└── sfmc_flutter/ (Application Flutter Web)

text

- **API Gateway** centralise toutes les requêtes et gère l’authentification JWT.
- **Base de données** : chaque microservice utilise une base SQLite locale (légère, sans serveur).
- **Communication inter‑services** : synchrone (REST via l’API Gateway) et asynchrone (émetteurs d’événements simples).
- **Frontend Flutter** : Material Design 3, responsive, avec Provider pour l’état.

---

## 🧰 Technologies utilisées

### Backend
- [Node.js](https://nodejs.org/) (Express)
- [better-sqlite3](https://github.com/WiseLibs/better-sqlite3) (base de données locale)
- [jsonwebtoken](https://www.npmjs.com/package/jsonwebtoken), [bcryptjs](https://www.npmjs.com/package/bcryptjs)
- [http-proxy-middleware](https://www.npmjs.com/package/http-proxy-middleware) (Gateway)
- [axios](https://www.npmjs.com/package/axios) (appels inter‑services)

### Frontend
- [Flutter](https://flutter.dev/) (Web, Windows)
- [Provider](https://pub.dev/packages/provider) (gestion d’état)
- [GoRouter](https://pub.dev/packages/go_router) (navigation)
- [fl_chart](https://pub.dev/packages/fl_chart), [syncfusion_flutter_charts](https://pub.dev/packages/syncfusion_flutter_charts) (graphiques)
- [data_table_2](https://pub.dev/packages/data_table_2), [badges](https://pub.dev/packages/badges), [shimmer](https://pub.dev/packages/shimmer)

---

## 🔧 Installation et démarrage

### Prérequis
- **Node.js** ≥ 18 (recommandé 20 LTS)
- **Flutter SDK** ≥ 3.30 (avec la configuration web)
- **Git**
- Un terminal (PowerShell, Bash, etc.)

### 1. Cloner le dépôt
```bash
git clone https://github.com/votre-username/sfmc-benin.git
cd sfmc-benin
2. Installer les dépendances backend
Pour chaque dossier de service dans backend/, exécutez :

bash
npm install
Vous pouvez le faire en une seule boucle (depuis backend/) :

bash
for d in */; do cd "$d" && npm install && cd ..; done
(Sous Windows, remplacez par une boucle PowerShell ou exécutez manuellement)

3. Démarrer les services backend
Ouvrez 10 consoles (ou utilisez le script start-all.bat fourni dans backend/) et lancez :

bash
cd backend/auth-service && node index.js
cd backend/user-service && node index.js
# ... et ainsi de suite pour les 9 autres services
Ordre conseillé : Auth → User → Product → Inventory → Order → Production → Billing → Notif → Reporting → Gateway

Le Gateway doit être lancé sans nodemon pour éviter les redémarrages intempestifs :

bash
cd backend/gateway
node index.js
Vérifiez que le Gateway répond :

text
http://localhost:3000/health
4. Lancer le frontend Flutter
bash
cd frontend/sfmc_flutter
flutter pub get
flutter run -d chrome   # ou -d edge
L’application s’ouvre dans le navigateur.

🔐 Identifiants de test
Rôle	Email	Mot de passe
Administrateur	admin@sfmc.bj	admin123
Opérateur	operateur@sfmc.bj	oper123
Client	client@sfmc.bj	client123
📦 Fonctionnalités principales
Authentification JWT sécurisée avec rôles (admin, opérateur, client)

Tableau de bord avec KPIs animés, graphiques et alertes

Catalogue produits (CRUD, filtres par catégorie)

Gestion des stocks multi‑entrepôts, mouvements, alertes de seuil critique

Commandes clients avec workflow (pending → livrée)

Planification de production, état des machines

Facturation et paiements (espèces, virement, chèque, mobile money)

Rapports analytiques (ventes, finances, production, stocks)

Notifications en temps réel (low stock, nouvel ordre)

Gestion des utilisateurs (admin)

📊 Exemples JSON d’API
POST /api/auth/login

json
{
  "email": "admin@sfmc.bj",
  "password": "admin123"
}
Réponse :

json
{
  "success": true,
  "token": "eyJhbGciOiJ...",
  "user": { "id": 1, "role": "admin" }
}
GET /api/inventory/alerts

json
{
  "success": true,
  "data": [
    { "product_name": "Ciment Portland", "quantity": 80, "seuil": 100 }
  ]
}
🧪 Tests
Des données de test (seed) sont automatiquement insérées au premier démarrage de chaque service :

5 utilisateurs

6 produits (ciment, fer, briques, granulats)

2 entrepôts avec stocks initiaux

5 commandes à différents stades

3 ordres de production avec machines

4 factures

🤝 Contribution
Les contributions sont les bienvenues ! Pour signaler un bug ou proposer une amélioration, ouvrez une issue ou soumettez une pull request.

📄 Licence
Ce projet est sous licence MIT. Voir le fichier LICENSE pour plus de détails.

Développé avec ❤️ pour la Société de Fabrication de Matériaux de Construction du Bénin.
