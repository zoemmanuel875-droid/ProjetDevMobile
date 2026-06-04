const pool = require('../database/db');
const bcrypt = require('bcryptjs');

class User {
  static async findByEmail(email) {
    const result = await pool.query('SELECT * FROM utilisateurs WHERE email = $1', [email]);
    return result.rows[0];
  }

  static async findById(id) {
    const result = await pool.query('SELECT id, nom, email, telephone, zone_preferee_id FROM utilisateurs WHERE id = $1', [id]);
    return result.rows[0];
  }

  static async create(nom, email, mot_de_passe, telephone = null) {
    const hashedPassword = await bcrypt.hash(mot_de_passe, 10);
    const result = await pool.query(
      'INSERT INTO utilisateurs (nom, email, mot_de_passe, telephone) VALUES ($1, $2, $3, $4) RETURNING id, nom, email',
      [nom, email, hashedPassword, telephone]
    );
    return result.rows[0];
  }

  static async verifyPassword(email, password) {
    const user = await this.findByEmail(email);
    if (!user) return null;
    const valid = await bcrypt.compare(password, user.mot_de_passe);
    return valid ? user : null;
  }

  static async updateProfile(id, nom, telephone) {
    const result = await pool.query(
      'UPDATE utilisateurs SET nom = $1, telephone = $2, updated_at = CURRENT_TIMESTAMP WHERE id = $3 RETURNING id, nom, email, telephone',
      [nom, telephone, id]
    );
    return result.rows[0];
  }

  static async setPreferredZone(userId, zoneId) {
    await pool.query(
      'UPDATE utilisateurs SET zone_preferee_id = $1 WHERE id = $2',
      [zoneId, userId]
    );
  }
}

module.exports = User;
