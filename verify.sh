#!/bin/bash

# FloodMap - Quick Verification Script
# Vérifie que tous les composants sont configurés correctement
# Usage: bash verify.sh

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "================================"
echo "🔍 FloodMap Verification Script"
echo "================================"
echo ""

# Counter
passed=0
failed=0

# Function to check command
check_command() {
    if command -v $1 &> /dev/null; then
        echo -e "${GREEN}✓${NC} $2"
        ((passed++))
    else
        echo -e "${RED}✗${NC} $2"
        ((failed++))
    fi
}

# Function to check file exists
check_file() {
    if [ -f "$1" ]; then
        echo -e "${GREEN}✓${NC} $2"
        ((passed++))
    else
        echo -e "${RED}✗${NC} $2 (Path: $1)"
        ((failed++))
    fi
}

# Function to check directory exists
check_dir() {
    if [ -d "$1" ]; then
        echo -e "${GREEN}✓${NC} $2"
        ((passed++))
    else
        echo -e "${RED}✗${NC} $2 (Path: $1)"
        ((failed++))
    fi
}

echo "📋 SYSTÈME"
check_command "node" "Node.js installé"
check_command "npm" "npm installé"
check_command "psql" "PostgreSQL installé"
check_command "flutter" "Flutter installé"
check_command "adb" "Android SDK/adb installé"

echo ""
echo "📁 STRUCTURE DE PROJET"
check_dir "floodmap-backend" "Dossier backend existe"
check_dir "lib" "Dossier lib (Flutter) existe"
check_dir "android" "Dossier android existe"
check_dir "ios" "Dossier ios existe"

echo ""
echo "⚙️ FICHIERS BACKEND"
check_file "floodmap-backend/.env" "Fichier .env configuré"
check_file "floodmap-backend/server.js" "Fichier server.js existe"
check_file "floodmap-backend/package.json" "Fichier package.json existe"
check_file "floodmap-backend/database/db.js" "Configuration DB existe"
check_file "floodmap-backend/models/User.js" "Modèle User existe"
check_file "floodmap-backend/models/Zone.js" "Modèle Zone existe"
check_file "floodmap-backend/models/Alert.js" "Modèle Alert existe"
check_file "floodmap-backend/middleware/auth.js" "Middleware auth existe"
check_file "floodmap-backend/routes/auth.js" "Route auth existe"
check_file "floodmap-backend/routes/zones.js" "Route zones existe"
check_file "floodmap-backend/routes/alertes.js" "Route alertes existe"

echo ""
echo "🎨 FICHIERS FRONTEND"
check_file "pubspec.yaml" "Fichier pubspec.yaml existe"
check_file "lib/main.dart" "Fichier main.dart existe"
check_file "lib/models/zone.dart" "Modèle Zone Dart existe"
check_file "lib/models/alert.dart" "Modèle Alert Dart existe"
check_file "lib/services/api_service.dart" "Service API existe"
check_file "lib/services/location_service.dart" "Service localisation existe"
check_file "lib/pages/login_page.dart" "Page login existe"
check_file "lib/pages/home_page.dart" "Page home existe"
check_file "lib/pages/alert_page.dart" "Page alertes existe"
check_file "lib/pages/map_page.dart" "Page map existe"
check_file "lib/pages/profil_page.dart" "Page profil existe"
check_file "lib/widgets/custom_button.dart" "Widget button existe"
check_file "lib/widgets/zone_card.dart" "Widget zone_card existe"

echo ""
echo "📚 DOCUMENTATION"
check_file "SETUP_GUIDE.md" "Guide de setup existe"
check_file "TROUBLESHOOTING.md" "Guide troubleshooting existe"
check_file "CORRECTIONS_SUMMARY.md" "Résumé des corrections existe"

echo ""
echo "================================"
echo "RÉSULTATS"
echo "================================"
echo -e "${GREEN}✓ Réussis: $passed${NC}"
echo -e "${RED}✗ Échoués: $failed${NC}"
echo ""

if [ $failed -eq 0 ]; then
    echo -e "${GREEN}🎉 TOUS LES VÉRIFICATIONS PASSÉES!${NC}"
    echo ""
    echo "Prochaines étapes:"
    echo "1. cd floodmap-backend && npm run dev"
    echo "2. emulator -avd Pixel_5"
    echo "3. flutter run"
    exit 0
else
    echo -e "${YELLOW}⚠️  Certaines vérifications ont échoué.${NC}"
    echo "Consulter SETUP_GUIDE.md pour plus d'informations"
    exit 1
fi
