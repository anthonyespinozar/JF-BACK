const pool = require("../config/db");

// Crear un nuevo dueño
const createOwner = async (req, res) => {
  try {
    const { nombre, apellido, dni, contacto } = req.body;

    const result = await pool.query(
      "INSERT INTO duenos (nombre, apellido, dni, contacto) VALUES ($1, $2, $3, $4) RETURNING *",
      [nombre, apellido, dni, contacto]
    );

    res.status(201).json(result.rows[0]);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// Obtener todos los dueños
const getAllOwners = async (req, res) => {
  try {
    const result = await pool.query("SELECT * FROM duenos ORDER BY nombre ASC");
    res.json(result.rows);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// Obtener un dueño por ID
const getOwnerById = async (req, res) => {
  try {
    const { id } = req.params;

    const result = await pool.query("SELECT * FROM duenos WHERE id = $1", [id]);

    if (result.rows.length === 0) {
      return res.status(404).json({ message: "Dueño no encontrado" });
    }

    res.json(result.rows[0]);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// Actualizar un dueño
const updateOwner = async (req, res) => {
  try {
    const { id } = req.params;
    const { nombre, apellido, dni, contacto } = req.body;

    const result = await pool.query(
      "UPDATE duenos SET nombre = $1, apellido = $2, dni = $3, contacto = $4 WHERE id = $5 RETURNING *",
      [nombre, apellido, dni, contacto, id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ message: "Dueño no encontrado" });
    }

    res.json(result.rows[0]);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// Eliminar un dueño
const deleteOwner = async (req, res) => {
  try {
    const { id } = req.params;

    const result = await pool.query("DELETE FROM duenos WHERE id = $1 RETURNING *", [id]);

    if (result.rows.length === 0) {
      return res.status(404).json({ message: "Dueño no encontrado" });
    }

    res.json({ message: "Dueño eliminado correctamente" });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

module.exports = {
  createOwner,
  getAllOwners,
  getOwnerById,
  updateOwner,
  deleteOwner
};
