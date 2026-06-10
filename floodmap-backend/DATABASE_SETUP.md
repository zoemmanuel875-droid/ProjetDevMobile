# 🚀 Guide de Configuration - FloodMap Application

## 📋 Prérequis

Avant de commencer, assurez-vous que vous avez :
- **PostgreSQL** installé et en cours d'exécution
- **Node.js** (v16+)
- **Flutter SDK** (pour l'application mobile)

---

## 🔧 Configuration Étape par Étape

### **Étape 1 : Vérifier PostgreSQL**

Ouvrez PowerShell et vérifiez que PostgreSQL est installé :

```powershell
psql --version
```

Si PostgreSQL n'est pas installé, téléchargez-le depuis : https://www.postgresql.org/download/

### **Étape 2 : Configurer les variables d'environnement**

Vérifiez le fichier `floodmap-backend\.env` :

```env
DB_USER=postgres
DB_PASSWORD=votre_mot_de_passe
DB_HOST=localhost
DB_PORT=5432
DB_NAME=floodmap_db
PORT=3000
```

⚠️ **Remplacez `votre_mot_de_passe`** par le mot de passe que vous avez défini lors de l'installation de PostgreSQL.

### **Étape 3 : Initialiser la Base de Données**

Dans PowerShell, allez dans le dossier backend :

```powershell
cd c:\Users\RAVELO\floodmap\floodmap-backend
```

Installez les dépendances :

```powershell
npm install
```

Initialisez la base de données :

```powershell
npm run init-db
```

Vous devriez voir :
```
✅ Connecté au serveur PostgreSQL
✅ Base de données "floodmap_db" créée
✅ Connecté à la base de données "floodmap_db"
✅ Tables créées avec succès
✅ Données de test insérées

🎉 Base de données initialisée avec succès!

📊 Tables créées:
   • utilisateurs
   • zones_inondables
   • alertes
   • historique_niveaux
   • favoris_zones
```

### **Étape 4 : Démarrer le Backend**

```powershell
npm run dev
```

Vous devriez voir :
```
🚀 Serveur FloodMap lancé sur http://localhost:3000
📍 Base de données connectée
✅ API prête pour l'émulateur Android Pixel 5
```

### **Étape 5 : Tester l'API**

Ouvrez un autre terminal PowerShell et testez la connexion :

```powershell
Invoke-WebRequest -Uri "http://localhost:3000/health"
```

Vous devriez obtenir :
```json
{
  "status": "API FloodMap en ligne",
  "timestamp": "2024-01-XX..."
}
```

### **Étape 6 : Lancer l'Application Flutter**

Dans un nouveau terminal, allez dans le dossier racine :

```powershell
cd c:\Users\RAVELO\floodmap
```

Lancez l'application :

```powershell
flutter run -v
```

---

## 🔗 Architecture

```
┌─────────────────────────────┐
│   App Flutter Mobile        │
│   (lib/main.dart)           │
└──────────┬──────────────────┘
           │
           │ HTTP/HTTPS
           ▼
┌─────────────────────────────┐
│   Node.js API Backend       │
│   (server.js - Port 3000)   │
└──────────┬──────────────────┘
           │
           │ Pool de connexions
           ▼
┌─────────────────────────────┐
│   PostgreSQL Database       │
│   - utilisateurs            │
│   - zones_inondables        │
│   - alertes                 │
│   - historique_niveaux      │
│   - favoris_zones           │
└─────────────────────────────┘
```

---

## 🧪 Tester l'API

### Créer un utilisateur (Inscription)

```powershell
$body = @{
    nom = "Ahmed Sidi"
    email = "ahmed@example.com"
    mot_de_passe = "Password123!"
    telephone = "21699123456"
} | ConvertTo-Json

Invoke-WebRequest -Uri "http://localhost:3000/api/auth/register" `
  -Method POST `
  -Headers @{"Content-Type"="application/json"} `
  -Body $body
```

### Connexion

```powershell
$body = @{
    email = "ahmed@example.com"
    mot_de_passe = "Password123!"
} | ConvertTo-Json

Invoke-WebRequest -Uri "http://localhost:3000/api/auth/login" `
  -Method POST `
  -Headers @{"Content-Type"="application/json"} `
  -Body $body
```

### Récupérer les zones

```powershell
Invoke-WebRequest -Uri "http://localhost:3000/api/zones" -Method GET
```

---

## ❌ Résoudre les Problèmes

### Erreur : "Base de données n'existe pas"
```powershell
npm run init-db
```

### Erreur : "Impossible de se connecter à PostgreSQL"
1. Vérifiez que PostgreSQL est en cours d'exécution
2. Vérifiez le mot de passe dans `.env`
3. Vérifiez que le port 5432 est accessible

### Erreur : "Module not found"
```powershell
npm install
```

### Erreur : "Port 3000 déjà utilisé"
Changez le port dans `.env` :
```env
PORT=3001
```

---

## 📝 Prochaines Étapes

1. ✅ Base de données configurée
2. ✅ Backend en cours d'exécution
3. ✅ API testée
4. ⏭️ Configurer les points de terminaison dans l'app Flutter
5. ⏭️ Tester l'intégration mobile

---

## 📞 Besoin d'aide?

Consultez les fichiers de troubleshooting :
- [TROUBLESHOOTING.md](../TROUBLESHOOTING.md)
- [SETUP_GUIDE.md](../SETUP_GUIDE.md)
