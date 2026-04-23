@echo off
echo Démarrage de SFMC Flutter Web...
flutter pub get
flutter run -d chrome --web-port=5000
pause