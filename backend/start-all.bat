@echo off
echo 🚀 Démarrage de tous les services SFMC Bénin...

cd backend\auth-service && start cmd /k npm run dev
cd backend\user-service && start cmd /k npm run dev
cd backend\product-service && start cmd /k npm run dev
cd backend\inventory-service && start cmd /k npm run dev
cd backend\order-service && start cmd /k npm run dev
cd backend\production-service && start cmd /k npm run dev
cd backend\billing-service && start cmd /k npm run dev
cd backend\notif-service && start cmd /k npm run dev
cd backend\reporting-service && start cmd /k npm run dev

echo ✅ Tous les services sont lancés !