// routes/orgAuthRoutes.js
const express = require('express');
const router = express.Router();
const { registerOrg, loginOrg } = require('../controllers/orgAuthController');

// @route   POST api/org-auth/register
// @desc    Register a new organization
// @access  Public
router.post('/register', registerOrg);

// @route   POST api/org-auth/login
// @desc    Login an organization
// @access  Public
router.post('/login', loginOrg);

module.exports = router;