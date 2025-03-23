const express = require("express");
const router = express.Router();
const userController = require("../controllers/user.controller");
const authenticate = require("../middlewares/auth.middleware");

// Activar o desactivar usuario (requiere autenticación)
router.put("/:id/status", authenticate, userController.toggleUserStatus);

module.exports = router;
