-- Créer la base de données floodmap_db
CREATE DATABASE floodmap_db;

-- Se connecter à la base de données
\c floodmap_db

-- Table des utilisateurs
CREATE TABLE utilisateurs (
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
CREATE TABLE zones_inondables (
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
CREATE TABLE alertes (
    id SERIAL PRIMARY KEY,
    zone_id INTEGER NOT NULL REFERENCES zones_inondables(id) ON DELETE CASCADE,
    message TEXT NOT NULL,
    niveau VARCHAR(50) DEFAULT 'info',
    envoyee_par INTEGER REFERENCES utilisateurs(id) ON DELETE SET NULL,
    est_lue BOOLEAN DEFAULT FALSE,
    date_alerte TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table de l'historique des niveaux d'eau
CREATE TABLE historique_niveaux (
    id SERIAL PRIMARY KEY,
    zone_id INTEGER NOT NULL REFERENCES zones_inondables(id) ON DELETE CASCADE,
    hauteur_eau_cm DECIMAL(8, 2) NOT NULL,
    date_mesure TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table des zones favorites par utilisateur
CREATE TABLE favoris_zones (
    id SERIAL PRIMARY KEY,
    utilisateur_id INTEGER NOT NULL REFERENCES utilisateurs(id) ON DELETE CASCADE,
    zone_id INTEGER NOT NULL REFERENCES zones_inondables(id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(utilisateur_id, zone_id)
);

-- Créer des index pour améliorer les performances
CREATE INDEX idx_utilisateurs_email ON utilisateurs(email);
CREATE INDEX idx_zones_inondables_nom ON zones_inondables(nom_zone);
CREATE INDEX idx_alertes_zone_id ON alertes(zone_id);
CREATE INDEX idx_historique_zone_id ON historique_niveaux(zone_id);
CREATE INDEX idx_favoris_utilisateur ON favoris_zones(utilisateur_id);

-- Données de test : Zones inondables
INSERT INTO zones_inondables (nom_zone, latitude, longitude, niveau_risque, hauteur_eau_cm, description) VALUES
('Zone Ribat Khcharem', 35.8089, 10.5946, 'moyen', 45, 'Zone résidentielle - bassin versant du Sebou'),
('Zone Sidi Bousaid', 36.8722, 10.2732, 'élevé', 72, 'Zone côtière - risque submersion marine'),
('Zone Nefta', 33.8611, 7.8833, 'critique', 95, 'Zone agricole - dépression naturelle'),
('Zone Médenine', 33.3611, 10.3967, 'bas', 20, 'Zone semi-aride - faible risque'),
('Zone Tabarka', 36.9572, 8.7549, 'moyen', 55, 'Zone touristique - rivières côtières');

COMMIT;
