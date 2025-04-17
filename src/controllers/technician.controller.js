const pool = require("../config/db");

// Obtener lista de técnicos
const getTechnicians = async (req, res) => {
  try {
    const result = await pool.query("SELECT id, nombre, especialidad, activo, creado_en FROM tecnicos ORDER BY id ASC");
    res.json(result.rows);
  } catch (error) {
    res.status(500).json({ error: "Error al obtener técnicos" });
  }
};

// Crear nuevo técnico
const createTechnician = async (req, res) => {
  try {
    const { nombre, especialidad, activo } = req.body;

    const result = await pool.query(
      "INSERT INTO tecnicos (nombre, especialidad, activo, creado_en) VALUES ($1, $2, $3, NOW()) RETURNING *",
      [nombre, especialidad, activo]
    );

    res.status(201).json({ message: "Técnico creado exitosamente", tecnico: result.rows[0] });
  } catch (error) {
    res.status(500).json({ error: "Error al crear técnico" });
  }
};

// Editar técnico
const updateTechnician = async (req, res) => {
  try {
    const { id } = req.params;
    const { nombre, especialidad } = req.body;

    const result = await pool.query(
      "UPDATE tecnicos SET nombre = $1, especialidad = $2 WHERE id = $3 RETURNING *",
      [nombre, especialidad, id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: "Técnico no encontrado" });
    }

    res.json({ message: "Técnico actualizado correctamente", tecnico: result.rows[0] });
  } catch (error) {
    res.status(500).json({ error: "Error al actualizar técnico" });
  }
};

// Activar o desactivar técnico
const toggleTechnicianStatus = async (req, res) => {
  try {
    const { id } = req.params;
    const { activo } = req.body;

    const result = await pool.query(
      "UPDATE tecnicos SET activo = $1 WHERE id = $2 RETURNING *",
      [activo, id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: "Técnico no encontrado" });
    }

    res.json({ message: `Técnico ${activo ? "activado" : "desactivado"} correctamente`, tecnico: result.rows[0] });
  } catch (error) {
    res.status(500).json({ error: "Error al cambiar estado del técnico" });
  }
};

module.exports = {
  getTechnicians,
  createTechnician,
  updateTechnician,
  toggleTechnicianStatus,
};
