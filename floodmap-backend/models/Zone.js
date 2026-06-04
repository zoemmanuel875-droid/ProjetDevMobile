const pool = require('../database/db');

class Zone {
  static async getAllZones() {
    const result = await pool.query(
      'SELECT id, nom_zone, latitude, longitude, niveau_risque, hauteur_eau_cm, description, dernier_releve FROM zones_inondables ORDER BY nom_zone'
    );
    return result.rows;
  }

  static async getZoneById(id) {
    const result = await pool.query(
      'SELECT * FROM zones_inondables WHERE id = $1',
      [id]
    );
    return result.rows[0];
  }

  static async getZonesByRisk() {
    const result = await pool.query(
      'SELECT id, nom_zone, latitude, longitude, niveau_risque, hauteur_eau_cm FROM zones_inondables ORDER BY CASE WHEN niveau_risque = \'critique\' THEN 1 WHEN niveau_risque = \'élevé\' THEN 2 WHEN niveau_risque = \'moyen\' THEN 3 ELSE 4 END'
    );
    return result.rows;
  }

  static async updateWaterLevel(zoneId, hauteurCm) {
    const result = await pool.query(
      'UPDATE zones_inondables SET hauteur_eau_cm = $1, dernier_releve = CURRENT_TIMESTAMP WHERE id = $2 RETURNING *',
      [hauteurCm, zoneId]
    );
    return result.rows[0];
  }

  static async getHistoricalData(zoneId, limit = 30) {
    const result = await pool.query(
      'SELECT hauteur_eau_cm, date_mesure FROM historique_niveaux WHERE zone_id = $1 ORDER BY date_mesure DESC LIMIT $2',
      [zoneId, limit]
    );
    return result.rows.reverse();
  }
}

module.exports = Zone;
