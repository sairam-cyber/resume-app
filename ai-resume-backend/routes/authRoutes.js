// routes/authRoutes.js
const express = require('express');
const router = express.Router();
const { register, login, registerGuest } = require('../controllers/authController');

// Define routes
router.post('/register', register);
router.post('/login', login);
router.post('/register-guest', registerGuest); // <-- ADDED THIS LINE

module.exports = router;