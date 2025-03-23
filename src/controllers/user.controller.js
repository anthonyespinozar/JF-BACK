const pool = require("../config/db");
const toggleUserStatus = async (req, res) => {
    try {
      const { id } = req.params;
      const { activo } = req.body; // Debe recibir TRUE o FALSE
  
      const result = await pool.query(
        "UPDATE usuarios SET activo = $1 WHERE id = $2 RETURNING *",
        [activo, id]
      );
  
      if (result.rows.length === 0) {
        return res.status(404).json({ error: "Usuario no encontrado" });
      }
  
      res.json({ message: `Usuario ${activo ? 'activado' : 'desactivado'} correctamente`, user: result.rows[0] });
    } catch (error) {
      res.status(500).json({ error: "Error al actualizar estado del usuario" });
    }
  };
  module.exports = {
    toggleUserStatus, // Nuevo reporte agregado
  };