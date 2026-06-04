# 🌊 FloodMap - Guide de Configuration et Lancement

## 📱 Application Mobile + Backend API

### Architecture
```
Frontend: Flutter (Dart) → Android Emulator Pixel 5
Backend: Node.js/Express → PostgreSQL
API: RESTful JSON
```

---

## 🔧 ÉTAPE 1 : Configuration PostgreSQL

### 1.1 Créer la base de données
```bash
psql -U postgres
```

Exécutez ce script SQL complet :

```sql
-- 1. Créer la base de données
CREATE DATABASE floodmap_db;
\c floodmap_db;

-- 2. Table utilisateurs
CREATE TABLE utilisateurs (
    id SERIAL PRIMARY KEY,
    nom VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    mot_de_passe VARCHAR(255) NOT NULL,
    telephone VARCHAR(20),
    zone_preferee_id INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 3. Table zones inondables
CREATE TABLE zones_inondables (
    id SERIAL PRIMARY KEY,
    nom_zone VARCHAR(100) NOT NULL,
    latitude DOUBLE PRECISION NOT NULL,
    longitude DOUBLE PRECISION NOT NULL,
    niveau_risque VARCHAR(20) CHECK (niveau_risque IN ('faible', 'moyen', 'élevé', 'critique')),
    hauteur_eau_cm DECIMAL(8,2) DEFAULT 0,
    description TEXT,
    dernier_releve TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    geom GEOMETRY(Point, 4326)
);

-- 4. Table alertes
CREATE TABLE alertes (
    id SERIAL PRIMARY KEY,
    zone_id INTEGER REFERENCES zones_inondables(id) ON DELETE CASCADE,
    message TEXT NOT NULL,
    niveau VARCHAR(20) CHECK (niveau IN ('info', 'vigilance', 'alerte', 'crue_majeure')),
    date_alerte TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    est_lue BOOLEAN DEFAULT FALSE,
    envoyee_par INTEGER REFERENCES utilisateurs(id)
);

-- 5. Table historique des niveaux d'eau
CREATE TABLE historique_niveaux (
    id SERIAL PRIMARY KEY,
    zone_id INTEGER REFERENCES zones_inondables(id) ON DELETE CASCADE,
    hauteur_eau_cm DECIMAL(8,2),
    date_mesure TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 6. Table favoris
CREATE TABLE favoris_zones (
    utilisateur_id INTEGER REFERENCES utilisateurs(id) ON DELETE CASCADE,
    zone_id INTEGER REFERENCES zones_inondables(id) ON DELETE CASCADE,
    date_ajout TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (utilisateur_id, zone_id)
);

-- 7. Indices pour performances
CREATE INDEX idx_zones_coords ON zones_inondables(latitude, longitude);
CREATE INDEX idx_alertes_zone ON alertes(zone_id);
CREATE INDEX idx_alertes_date ON alertes(date_alerte DESC);
CREATE INDEX idx_historique_zone ON historique_niveaux(zone_id);

-- 8. Données de test
INSERT INTO utilisateurs (nom, email, mot_de_passe) VALUES 
('Admin Flood', 'admin@floodmap.com', 'motdepasse_hashé');

INSERT INTO zones_inondables (nom_zone, latitude, longitude, niveau_risque, hauteur_eau_cm, description) VALUES
('Zone Nord', 48.8566, 2.3522, 'moyen', 120, 'Secteur résidentiel proche rivière'),
('Zone Est', 48.8600, 2.3600, 'élevé', 250, 'Ancienne zone marécageuse'),
('Zone Ouest', 48.8500, 2.3400, 'faible', 30, 'Zone avec digues récentes');

INSERT INTO alertes (zone_id, message, niveau) VALUES
(1, 'Montée des eaux détectée', 'vigilance'),
(2, 'Alerte inondation émise', 'alerte'),
(3, 'Situation normale', 'info');
```

---

## 🚀 ÉTAPE 2 : Configuration Backend Node.js

### 2.1 Installer les dépendances
```bash
cd floodmap-backend
npm install
```

### 2.2 Vérifier le .env
Fichier: `floodmap-backend/.env`
```
PORT=3000
DB_USER=postgres
DB_PASSWORD=1234
DB_HOST=localhost
DB_PORT=5432
DB_NAME=floodmap_db

JWT_SECRET=votre_secret_jwt_tres_securise_ici_2024

NODE_ENV=development
```

**⚠️ Adaptez `DB_PASSWORD` si nécessaire**

### 2.3 Lancer le serveur
```bash
npm run dev
```

Ou en production :
```bash
npm start
```

✅ Vous devriez voir :
```
🚀 Serveur FloodMap lancé sur http://localhost:3000
📍 Base de données connectée
✅ API prête pour l'émulateur Android Pixel 5
```

### 2.4 Tester l'API
```bash
curl http://localhost:3000/health

# Résultat attendu:
{"status": "API FloodMap en ligne", "timestamp": "..."}
```

---

## 📱 ÉTAPE 3 : Configuration Flutter

### 3.1 Installer les dépendances Dart
```bash
cd /path/to/floodmap
flutter clean
flutter pub get
```

### 3.2 Vérifier les permissions Android
Fichier: `android/app/src/main/AndroidManifest.xml`

Ajoutez si absent :
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

### 3.3 Démarrer l'émulateur Pixel 5
```bash
# Voir les émulateurs disponibles
emulator -list-avds

# Lancer Pixel 5
emulator -avd Pixel_5 -netdelay none -netspeed full
```

ou via Android Studio : 
- Device Manager → Select Pixel 5 → Launch

### 3.4 Vérifier la connexion réseau
Dans l'émulateur, testez la connectivité :
```bash
adb shell
ping 10.0.2.4
```

✅ Le serveur Node.js doit répondre sur `10.0.2.4:3000`

---

## 🔌 ÉTAPE 4 : Lancer l'application Flutter

### 4.1 Build et run
```bash
flutter run
```

Ou spécifiez l'appareil :
```bash
flutter devices  # voir les appareils disponibles
flutter run -d emulator-5554  # lancer sur Pixel 5
```

### 4.2 Résoudre les problèmes courants

**Erreur : "Impossible de se connecter à l'API"**
```bash
# Vérifiez que le serveur Node.js fonctionne
curl http://localhost:3000/health

# Testez la connectivité depuis l'émulateur
adb shell ping 10.0.2.4
```

**Erreur : "Build Error"**
```bash
flutter clean
flutter pub get
flutter run
```

**Erreur : "Permission denied"**
```bash
# Accordez les permissions dans l'app
# Les permissions de localisation sont demandées au premier lancement
```

---

## 📋 ENDPOINTS API DISPONIBLES

### Authentification
```
POST   /api/auth/register      - Créer un compte
POST   /api/auth/login         - Se connecter
GET    /api/auth/profile       - Récupérer profil (auth requis)
PUT    /api/auth/profile       - Mettre à jour profil (auth requis)
```

### Zones
```
GET    /api/zones              - Toutes les zones
GET    /api/zones/:id          - Zone spécifique
GET    /api/zones/:id/historique - Historique des niveaux d'eau
POST   /api/zones/:id/favoris  - Ajouter aux favoris (auth requis)
DELETE /api/zones/:id/favoris  - Retirer des favoris (auth requis)
```

### Alertes
```
GET    /api/alertes            - Toutes les alertes
GET    /api/alertes/zone/:zoneId - Alertes d'une zone
POST   /api/alertes            - Créer une alerte (auth requis)
PUT    /api/alertes/:id/lue    - Marquer comme lue (auth requis)
```

---

## 🧪 TESTER L'APPLICATION

### 1️⃣ Créer un compte
1. Ouvrir l'app Flutter
2. Cliquer sur "Pas de compte? Créer un"
3. Remplir le formulaire :
   - Nom: `Test User`
   - Email: `test@floodmap.com`
   - Mot de passe: `Password123`
   - Téléphone: `+33123456789`

### 2️⃣ Se connecter
1. Email: `test@floodmap.com`
2. Mot de passe: `Password123`

### 3️⃣ Explorer les zones
1. Tab "Zones" → Voir les 3 zones test
2. Cliquer sur une zone pour voir les détails
3. Voir les alertes pour cette zone

### 4️⃣ Consulter les alertes
1. Tab "Alertes" → Voir toutes les alertes
2. Cliquer sur une alerte pour voir les détails

### 5️⃣ Gérer le profil
1. Tab "Profil" → Voir les options
2. Déconnexion → Retour à l'écran login

---

## 🐛 DÉBOGAGE

### Activez les logs
```bash
# Terminal 1 : Backend
npm run dev

# Terminal 2 : Flutter
flutter run -v

# Terminal 3 : Monitorer la BD
psql -U postgres -d floodmap_db
SELECT * FROM zones_inondables;
SELECT * FROM alertes;
```

### Testez l'API avec Postman
1. Téléchargez Postman
2. Importez ou créez des requêtes :
   - POST http://localhost:3000/api/auth/register
   - GET http://localhost:3000/api/zones
   - GET http://localhost:3000/health

---

## 📊 STRUCTURE DES DONNÉES

### Zone
```json
{
  "id": 1,
  "nom_zone": "Zone Nord",
  "latitude": 48.8566,
  "longitude": 2.3522,
  "niveau_risque": "moyen",
  "hauteur_eau_cm": 120,
  "description": "Secteur résidentiel proche rivière",
  "dernier_releve": "2024-06-04T10:00:00Z"
}
```

### Alerte
```json
{
  "id": 1,
  "zone_id": 1,
  "nom_zone": "Zone Nord",
  "message": "Montée des eaux détectée",
  "niveau": "vigilance",
  "date_alerte": "2024-06-04T10:00:00Z",
  "est_lue": false
}
```

### Utilisateur
```json
{
  "id": 1,
  "nom": "Test User",
  "email": "test@floodmap.com",
  "telephone": "+33123456789"
}
```

---

## ✅ CHECKLIST DE VÉRIFICATION

- [ ] PostgreSQL installé et base créée
- [ ] Backend Node.js lancé sur port 3000
- [ ] Émulateur Pixel 5 en cours d'exécution
- [ ] API répond à http://localhost:3000/health
- [ ] Flutter dependencies installées (`flutter pub get`)
- [ ] Application lancée avec `flutter run`
- [ ] Connexion réussie avec test@floodmap.com
- [ ] Zones affichées dans l'onglet "Zones"
- [ ] Alertes affichées dans l'onglet "Alertes"
- [ ] Navigation entre les onglets fonctionne

---

## 📞 SUPPORT

**Problèmes de connexion réseau:**
```bash
# Depuis l'émulateur
adb shell ping 10.0.2.4:3000
```

**Erreurs de base de données:**
```bash
psql -U postgres -d floodmap_db -c "\dt"  # voir tables
```

**Problèmes Flutter:**
```bash
flutter doctor -v  # diagnostic complet
```

---

## 🎯 PROCHAINES ÉTAPES

1. **Intégrer Google Maps** pour une vraie carte
2. **Ajouter notifications** en temps réel (WebSockets)
3. **Implémenter GPS tracking** pour détecter automatiquement les zones proches
4. **Ajouter historique graphique** des niveaux d'eau
5. **Déployer backend** sur serveur cloud (AWS, Azure, Heroku)

---

**Version**: 1.0.0  
**Dernière mise à jour**: 4 Juin 2024
