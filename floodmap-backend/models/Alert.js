const pool = require('../database/db');

class Alert {
  static async getAlertsByZone(zoneId, limit = 10) {
    const result = await pool.query(
      'SELECT a.id, a.zone_id, a.message, a.niveau, a.date_alerte, a.est_lue, u.nom as envoyee_par_nom FROM alertes a LEFT JOIN utilisateurs u ON a.envoyee_par = u.id WHERE a.zone_id = $1 ORDER BY a.date_alerte DESC LIMIT $2',
      [zoneId, limit]
    );
    return result.rows;
  }

  static async getUnreadAlerts(userId) {
    const result = await pool.query(
      'SELECT a.id, a.zone_id, z.nom_zone, a.message, a.niveau, a.date_alerte FROM alertes a JOIN zones_inondables z ON a.zone_id = z.id WHERE a.est_lue = FALSE AND z.id IN (SELECT zone_id FROM favoris_zones WHERE utilisateur_id = $1) ORDER BY a.date_alerte DESC',
      [userId]
    );
    return result.rows;
  }

  static async createAlert(zoneId, message, niveau, userId = null) {
    const result = await pool.query(
      'INSERT INTO alertes (zone_id, message, niveau, envoyee_par) VALUES ($1, $2, $3, $4) RETURNING *',
      [zoneId, message, niveau, userId]
    );
    return result.rows[0];
  }

  static async markAsRead(alertId) {
    await pool.query('UPDATE alertes SET est_lue = TRUE WHERE id = $1', [alertId]);
  }

  static async getAllAlerts(limit = 50) {
    const result = await pool.query(
      'SELECT a.id, a.zone_id, z.nom_zone, a.message, a.niveau, a.date_alerte, a.est_lue FROM alertes a JOIN zones_inondables z ON a.zone_id = z.id ORDER BY a.date_alerte DESC LIMIT $1',
      [limit]
    );
    return result.rows;
  }
}

module.exports = Alert;
