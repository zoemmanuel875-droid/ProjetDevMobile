# 🔧 Troubleshooting - Résolution des Problèmes FloodMap

## 🚨 PROBLÈMES COURANTS

### ❌ L'émulateur Pixel 5 ne démarre pas

**Symptôme**: `emulator -avd Pixel_5` reste bloqué ou affiche une erreur

**Solutions**:
```bash
# 1. Vérifiez la liste des AVD
emulator -list-avds

# 2. Si Pixel_5 n'existe pas, créez-le
avdmanager create avd -n Pixel_5 -k "system-images;android-34;google_apis;x86_64"

# 3. Lancez avec options spéciales
emulator -avd Pixel_5 -netdelay none -netspeed full -wipe-data

# 4. Depuis Android Studio
# Device Manager → Create Device → Pixel 5 → Download system image → Launch
```

---

### ❌ Erreur: "Impossible de se connecter à 10.0.2.4:3000"

**Symptôme**: L'app Flutter affiche "Erreur: Failed connection" quand elle essaie d'accéder à l'API

**Vérifications**:
```bash
# 1. Le serveur Node.js tourne-t-il ?
curl http://localhost:3000/health
# Doit retourner: {"status": "API FloodMap en ligne", ...}

# 2. Testez depuis l'émulateur
adb shell
ping 10.0.2.4
# Doit afficher des pings réussis

# 3. Testez une requête HTTP complète
adb shell curl http://10.0.2.4:3000/health

# 4. Vérifiez le pare-feu Windows
# Windows Defender Firewall → Allow app through firewall → Node.js
```

**Solutions**:
```bash
# Redémarrez l'émulateur
adb emu kill
emulator -avd Pixel_5

# Redémarrez le serveur Node.js
cd floodmap-backend
npm run dev

# Videz le cache Flutter
flutter clean
flutter pub get
flutter run
```

---

### ❌ PostgreSQL : "psql: command not found"

**Symptôme**: Erreur quand vous tapez `psql`

**Solutions**:
```bash
# Windows : Ajoutez PostgreSQL au PATH
# 1. Ouvrez Environment Variables
# 2. Ajoutez: C:\Program Files\PostgreSQL\15\bin (ou votre version)
# 3. Redémarrez le terminal

# Vérifiez l'installation
psql --version
```

---

### ❌ Erreur: "database floodmap_db does not exist"

**Symptôme**: Le backend refuse de se connecter

**Vérification**:
```bash
# Connectez-vous à PostgreSQL
psql -U postgres

# Dans psql, tapez:
\l
# Cherchez "floodmap_db"

# Si absent, créez-la
CREATE DATABASE floodmap_db;
\c floodmap_db;

# Exécutez le script SQL complet du SETUP_GUIDE.md
```

---

### ❌ Erreur: "FATAL: Ident authentication failed for user "postgres""

**Symptôme**: PostgreSQL refuse la connexion

**Solutions**:
```bash
# Editez pg_hba.conf
# Localisation: C:\Program Files\PostgreSQL\15\data\pg_hba.conf
# Changez "ident" en "md5" ou "trust" pour local connections

# Redémarrez PostgreSQL
# Windows Services → postgresql-x64-15 → Restart

# Ou via terminal
pg_ctl restart -D "C:\Program Files\PostgreSQL\15\data"
```

---

### ❌ Flutter build error: "FAILURE: Build failed"

**Symptôme**: `flutter run` échoue avec erreur Gradle

**Solutions**:
```bash
# Nettoyez et refaites le build
flutter clean
flutter pub get
flutter pub cache repair
flutter run

# Sinon, force une recréation du projet Android
cd android
./gradlew clean
cd ..
flutter run

# Si toujours bloqué, mettez à jour Flutter
flutter upgrade
```

---

### ❌ Erreur: "Cannot allocate memory"

**Symptôme**: L'émulateur ou le compilateur échoue

**Solutions**:
```bash
# Augmentez la RAM d'Android Studio
# File → Settings → System Settings → Memory
# Augmentez à 4096 MB ou plus

# Relancez l'émulateur
adb devices -l  # Voir les appareils actuels
adb emu kill    # Tuer l'émulateur

# Allouez plus de RAM à l'AVD
emulator -avd Pixel_5 -memory 2048 -verbose
```

---

### ❌ Erreur: "Port 3000 already in use"

**Symptôme**: `npm run dev` échoue - le port est déjà utilisé

**Solutions**:
```bash
# Windows : Trouvez le processus qui utilise le port 3000
netstat -ano | findstr :3000
# Notez le PID, puis terminez-le
taskkill /PID <PID> /F

# Linux/Mac :
lsof -i :3000
kill -9 <PID>

# Ou changez le port dans .env
PORT=3001
```

---

### ❌ Erreur: "No visible devices" quand on lance `flutter run`

**Symptôme**: Flutter ne voit pas l'émulateur

**Solutions**:
```bash
# Vérifiez les appareils connectés
flutter devices

# Relancez le daemon
flutter clean
adb devices -l
flutter run

# Redémarrez tout
adb kill-server
adb start-server
emulator -avd Pixel_5 &
flutter run
```

---

### ❌ API retourne: "Token invalide" ou "Token manquant"

**Symptôme**: Après connexion, les appels à l'API échouent

**Solutions**:
```bash
# Vérifiez que SharedPreferences sauvegarde le token
# Dans l'app, ajoutez des logs:
print('Token: ${await ApiService.getToken()}');

# Vérifiez que JWT_SECRET dans .env est configuré
echo "JWT_SECRET=" >> floodmap-backend/.env

# Redémarrez le backend
npm run dev
```

---

### ❌ Base de données: "Relation "users" does not exist"

**Symptôme**: Tables PostgreSQL non créées

**Solutions**:
```bash
# Vérifiez que vous êtes connecté à floodmap_db
psql -U postgres -d floodmap_db -c "\dt"

# Listez les tables
\dt

# Si vide, exécutez le script SQL complet
# Copier-coller le code du SETUP_GUIDE.md
```

---

## ⚠️ AVERTISSEMENTS

### Performance
```
- L'émulateur Pixel 5 peut être lent, surtout sur machines faibles
- Utilisez "-netdelay none -netspeed full" pour de meilleures performances
- 8GB RAM recommandé pour l'émulateur + IDE + DB
```

### Sécurité
```
- Ne commitez JAMAIS le .env en production
- Changez JWT_SECRET en production
- Utilisez HTTPS en production (pas HTTP)
- Validez TOUS les inputs utilisateur côté backend
```

### Base de données
```
- Sauvegardez floodmap_db avant les migrations
pg_dump -U postgres floodmap_db > backup.sql

- Restaurez si besoin
psql -U postgres -d floodmap_db < backup.sql
```

---

## 🔍 DIAGNOSTICS UTILES

### Vérifier la connectivité réseau
```bash
# Depuis l'hôte
ipconfig getifaddr en0  # Mac
ipconfig | findstr "IPv4"  # Windows

# Depuis l'émulateur
adb shell ip addr show
adb shell netstat -tuln | grep LISTEN
```

### Logs de la base de données
```bash
# PostgreSQL logs
SELECT name, setting FROM pg_settings WHERE name IN ('log_min_duration_statement', 'log_statement');

# Activez les logs détaillés
ALTER SYSTEM SET log_statement = 'all';
SELECT pg_reload_conf();
```

### Logs Flutter avancés
```bash
flutter run -v 2>&1 | tee flutter_debug.log
# Analysez flutter_debug.log pour les erreurs
```

---

## ✅ CHECKLIST AVANT DE DÉPLOYER

- [ ] PostgreSQL fonctionne localement
- [ ] Backend Node.js fonctionne sur localhost:3000
- [ ] Émulateur Pixel 5 démarre sans erreur
- [ ] `flutter run` build l'app sans erreur
- [ ] Création de compte fonctionne
- [ ] Connexion fonctionne
- [ ] Zones affichées correctement
- [ ] Alertes affichées correctement
- [ ] Pas d'erreurs dans les logs Flutter
- [ ] Pas d'erreurs dans la console Node.js

---

## 📞 GETTING HELP

1. Vérifiez cette liste
2. Vérifiez les logs complets
3. Recherchez l'erreur exacte sur Google
4. Consultez la doc officielle (Flutter.dev, nodejs.org, postgresql.org)

---

**Dernière mise à jour**: 4 Juin 2024
