const pool = require("../config/db");

// Crear una unidad
const createUnit = async (req, res) => {
  try {
    const { placa, modelo, año, tipo, chofer_id, kilometraje, dueno_id } = req.body;

    const result = await pool.query(
      `INSERT INTO unidades (placa, modelo, año, tipo, chofer_id, kilometraje, dueno_id) 
       VALUES ($1, $2, $3, $4, $5, $6, $7) RETURNING *`,
      [placa, modelo, año, tipo, chofer_id, kilometraje, dueno_id]
    );

    res.status(201).json(result.rows[0]);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// Obtener todas las unidades con información del dueño
const getAllUnits = async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT u.*, d.nombre AS dueno_nombre, d.apellido AS dueno_apellido, d.dni AS dueno_dni
      FROM unidades u
      LEFT JOIN duenos d ON u.dueno_id = d.id
      ORDER BY u.creado_en DESC
    `);
    res.json(result.rows);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// Obtener unidades por dueño
const getUnitsByOwner = async (req, res) => {
  try {
    const { duenoId } = req.params;

    const result = await pool.query(
      "SELECT * FROM unidades WHERE dueno_id = $1",
      [duenoId]
    );

    res.json(result.rows);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// Obtener una unidad por ID
const getUnitById = async (req, res) => {
  try {
    const { id } = req.params;

    const result = await pool.query("SELECT * FROM unidades WHERE id = $1", [id]);

    if (result.rows.length === 0) {
      return res.status(404).json({ message: "Unidad no encontrada" });
    }

    res.json(result.rows[0]);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// Actualizar una unidad
const updateUnit = async (req, res) => {
  try {
    const { id } = req.params;
    const { placa, modelo, año, tipo, chofer_id, kilometraje, dueno_id } = req.body;

    const result = await pool.query(
      `UPDATE unidades 
       SET placa = $1, modelo = $2, año = $3, tipo = $4, chofer_id = $5, kilometraje = $6, dueno_id = $7
       WHERE id = $8 RETURNING *`,
      [placa, modelo, año, tipo, chofer_id, kilometraje, dueno_id, id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ message: "Unidad no encontrada" });
    }

    res.json(result.rows[0]);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// Eliminar una unidad
const deleteUnit = async (req, res) => {
  try {
    const { id } = req.params;

    const result = await pool.query("DELETE FROM unidades WHERE id = $1 RETURNING *", [id]);

    if (result.rows.length === 0) {
      return res.status(404).json({ message: "Unidad no encontrada" });
    }

    res.json({ message: "Unidad eliminada correctamente" });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

module.exports = {
  createUnit,
  getAllUnits,
  getUnitsByOwner,
  getUnitById,
  updateUnit,
  deleteUnit,
};
