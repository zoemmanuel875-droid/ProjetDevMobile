# 🔧 Troubleshooting - Erreurs de Connexion API

## ❌ Erreur: "ERR_CONNECTION_TIMED_OUT" sur /api/auth/register

### Cause Principale
Le serveur Node.js n'écoutait que sur `localhost` et n'était pas accessible de l'émulateur Android.

### ✅ Solution Appliquée
- ✅ Serveur modifié pour écouter sur `0.0.0.0` (toutes les interfaces)
- ✅ Api_service.dart amélioré avec timeouts et logs détaillés

---

## 🚀 Étapes pour Corriger

### **1. Redémarrer le serveur Backend**

Dans PowerShell, arrêtez le serveur (Ctrl+C) et relancez-le :

```powershell
npm run dev
```

Vous devriez voir :
```
🚀 Serveur FloodMap lancé sur http://0.0.0.0:3000
📍 Accessible de l'émulateur via: http://10.0.2.4:3000
✅ Base de données connectée
✅ API prête pour l'émulateur Android Pixel 5
```

### **2. Nettoyer et Relancer l'App Flutter**

Dans un autre terminal PowerShell :

```powershell
cd c:\Users\RAVELO\floodmap

# Nettoyer les caches
flutter clean

# Récupérer les dépendances
flutter pub get

# Relancer en mode verbose pour voir les logs
flutter run -v
```

### **3. Vérifier les Logs**

Dans les logs Flutter, vous devriez voir :

```
🔐 Tentative d'inscription vers: http://10.0.2.4:3000/api/auth/register
✅ Réponse reçue: 201
✅ Alerte créée
```

---

## 🧪 Tester la Connexion API

### Test 1 : Vérifier que le serveur écoute

```powershell
# Depuis votre machine hôte
curl http://localhost:3000/health

# Résultat attendu:
# {"status":"API FloodMap en ligne","timestamp":"2024-01-..."}
```

### Test 2 : Enregistrement d'utilisateur

```powershell
$body = @{
    nom = "Test User"
    email = "test@example.com"
    mot_de_passe = "TestPass123!"
    telephone = "21699999999"
} | ConvertTo-Json

Invoke-WebRequest -Uri "http://localhost:3000/api/auth/register" `
  -Method POST `
  -Headers @{"Content-Type"="application/json"} `
  -Body $body
```

### Test 3 : Connexion

```powershell
$body = @{
    email = "test@example.com"
    mot_de_passe = "TestPass123!"
} | ConvertTo-Json

Invoke-WebRequest -Uri "http://localhost:3000/api/auth/login" `
  -Method POST `
  -Headers @{"Content-Type"="application/json"} `
  -Body $body
```

---

## ⚙️ Vérifier la Configuration

### Vérifier les Variables d'Environnement

```powershell
cd c:\Users\RAVELO\floodmap\floodmap-backend
cat .env

# Devrait afficher:
# DB_USER=postgres
# DB_PASSWORD=votre_mot_de_passe
# DB_HOST=localhost
# DB_PORT=5432
# DB_NAME=floodmap_db
# PORT=3000
```

### Vérifier que PostgreSQL est en cours d'exécution

```powershell
# Windows: Vérifier le service
Get-Service postgresql*

# Ou se connecter à la DB
psql -U postgres -d floodmap_db -c "SELECT COUNT(*) FROM utilisateurs;"
```

---

## 🔌 Problèmes Réseau Spécifiques

### Erreur: "Serveur inaccessible (timeout)"

**Possible cause 1: Firewall Windows**
```powershell
# Autoriser le port 3000
netsh advfirewall firewall add rule name="Node.js API" `
  dir=in action=allow protocol=tcp localport=3000
```

**Possible cause 2: Émulateur ne peut pas accéder à la machine hôte**
```
- Vérifier que 10.0.2.4 est utilisé (not localhost ou 127.0.0.1)
- Redémarrer l'émulateur: flutter emulators --launch Pixel_5_API_30
```

**Possible cause 3: Port 3000 déjà utilisé**
```powershell
# Trouver le processus
netstat -ano | findstr :3000

# Terminer le processus (remplacer PID)
taskkill /PID <PID> /F

# Ou changer le port dans .env
# PORT=3001
```

---

## 📊 Architecture Corrigée

```
┌─────────────────────────────────┐
│   Émulateur Android             │
│   (Flutter App)                 │
│   http://10.0.2.4:3000/api      │
└──────────┬──────────────────────┘
           │ (connexion TCP/IP)
           ▼
┌─────────────────────────────────┐
│   Machine Hôte Windows          │
│   Node.js Server                │
│   0.0.0.0:3000 (toutes les IPs) │
└──────────┬──────────────────────┘
           │ (pool de connexions)
           ▼
┌─────────────────────────────────┐
│   PostgreSQL Database           │
│   localhost:5432                │
└─────────────────────────────────┘
```

---

## ✅ Checklist Finale

- [ ] Serveur relancé avec `npm run dev`
- [ ] Logs montrent `0.0.0.0:3000`
- [ ] App Flutter nettoyée avec `flutter clean`
- [ ] App relancée avec `flutter run -v`
- [ ] Logs Flutter montrent `10.0.2.4:3000/api/auth/register`
- [ ] API répond aux tests PowerShell
- [ ] PostgreSQL est connectée
- [ ] Utilisateur peut s'inscrire et se connecter

---

## 📞 Si le problème persiste

1. Vérifier les logs PowerShell du serveur Node.js
2. Vérifier les logs Flutter (flutter run -v)
3. Vérifier la connexion DB avec : `npm run init-db`
4. Relancer l'émulateur Android
5. Vérifier le firewall Windows

