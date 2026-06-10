const { Client } = require('pg');
require('dotenv').config();

async function initializeDatabase() {
  console.log('🔧 Initialisation de la base de données FloodMap...\n');

  // Connexion au serveur PostgreSQL (sans base de données spécifique)
  const adminClient = new Client({
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    host: process.env.DB_HOST,
    port: process.env.DB_PORT,
  });

  try {
    await adminClient.connect();
    console.log('✅ Connecté au serveur PostgreSQL');

    // Créer la base de données
    try {
      await adminClient.query(`CREATE DATABASE ${process.env.DB_NAME};`);
      console.log(`✅ Base de données "${process.env.DB_NAME}" créée`);
    } catch (err) {
      if (err.code === '42P04') {
        console.log(`⚠️  Base de données "${process.env.DB_NAME}" existe déjà`);
      } else {
        throw err;
      }
    }

    await adminClient.end();

    // Connexion à la nouvelle base de données
    const pool = new Client({
      user: process.env.DB_USER,
      password: process.env.DB_PASSWORD,
      host: process.env.DB_HOST,
      port: process.env.DB_PORT,
      database: process.env.DB_NAME,
    });

    await pool.connect();
    console.log(`✅ Connecté à la base de données "${process.env.DB_NAME}"`);

    // Créer les tables
    const createTablesSQL = `
    -- Table des utilisateurs
    CREATE TABLE IF NOT EXISTS utilisateurs (
        id SERIAL PRIMARY KEY,
        nom VARCHAR(255) NOT NULL,
        email VARCHAR(255) UNIQUE NOT NULL,
        mot_de_passe VARCHAR(255) NOT NULL,
        telephone VARCHAR(20),
        zone_preferee_id INTEGER,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );

    -- Table des zones inondables
    CREATE TABLE IF NOT EXISTS zones_inondables (
        id SERIAL PRIMARY KEY,
        nom_zone VARCHAR(255) NOT NULL,
        latitude DECIMAL(10, 8) NOT NULL,
        longitude DECIMAL(11, 8) NOT NULL,
        niveau_risque VARCHAR(50) DEFAULT 'bas',
        hauteur_eau_cm DECIMAL(8, 2) DEFAULT 0,
        description TEXT,
        dernier_releve TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );

    -- Table des alertes
    CREATE TABLE IF NOT EXISTS alertes (
        id SERIAL PRIMARY KEY,
        zone_id INTEGER NOT NULL REFERENCES zones_inondables(id) ON DELETE CASCADE,
        message TEXT NOT NULL,
        niveau VARCHAR(50) DEFAULT 'info',
        envoyee_par INTEGER REFERENCES utilisateurs(id) ON DELETE SET NULL,
        est_lue BOOLEAN DEFAULT FALSE,
        date_alerte TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );

    -- Table de l'historique des niveaux d'eau
    CREATE TABLE IF NOT EXISTS historique_niveaux (
        id SERIAL PRIMARY KEY,
        zone_id INTEGER NOT NULL REFERENCES zones_inondables(id) ON DELETE CASCADE,
        hauteur_eau_cm DECIMAL(8, 2) NOT NULL,
        date_mesure TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );

    -- Table des zones favorites
    CREATE TABLE IF NOT EXISTS favoris_zones (
        id SERIAL PRIMARY KEY,
        utilisateur_id INTEGER NOT NULL REFERENCES utilisateurs(id) ON DELETE CASCADE,
        zone_id INTEGER NOT NULL REFERENCES zones_inondables(id) ON DELETE CASCADE,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        UNIQUE(utilisateur_id, zone_id)
    );

    -- Créer les index
    CREATE INDEX IF NOT EXISTS idx_utilisateurs_email ON utilisateurs(email);
    CREATE INDEX IF NOT EXISTS idx_zones_inondables_nom ON zones_inondables(nom_zone);
    CREATE INDEX IF NOT EXISTS idx_alertes_zone_id ON alertes(zone_id);
    CREATE INDEX IF NOT EXISTS idx_historique_zone_id ON historique_niveaux(zone_id);
    CREATE INDEX IF NOT EXISTS idx_favoris_utilisateur ON favoris_zones(utilisateur_id);
    `;

    await pool.query(createTablesSQL);
    console.log('✅ Tables créées avec succès');

    // Insérer des données de test
    const insertSampleData = `
    INSERT INTO zones_inondables (nom_zone, latitude, longitude, niveau_risque, hauteur_eau_cm, description) 
    VALUES 
      ('Zone Ribat Khcharem', 35.8089, 10.5946, 'moyen', 45, 'Zone résidentielle'),
      ('Zone Sidi Bousaid', 36.8722, 10.2732, 'élevé', 72, 'Zone côtière'),
      ('Zone Nefta', 33.8611, 7.8833, 'critique', 95, 'Zone agricole'),
      ('Zone Médenine', 33.3611, 10.3967, 'bas', 20, 'Zone semi-aride'),
      ('Zone Tabarka', 36.9572, 8.7549, 'moyen', 55, 'Zone touristique')
    ON CONFLICT DO NOTHING;
    `;

    await pool.query(insertSampleData);
    console.log('✅ Données de test insérées');

    await pool.end();

    console.log('\n🎉 Base de données initialisée avec succès!\n');
    console.log('📊 Tables créées:');
    console.log('   • utilisateurs');
    console.log('   • zones_inondables');
    console.log('   • alertes');
    console.log('   • historique_niveaux');
    console.log('   • favoris_zones');

  } catch (error) {
    console.error('❌ Erreur lors de l\'initialisation:', error.message);
    process.exit(1);
  }
}

initializeDatabase();
