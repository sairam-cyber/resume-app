// routes/orgRoutes.js
const express = require('express');
const router = express.Router();
const { getMeOrg, updateMeOrg } = require('../controllers/orgController');
const authMiddleware = require('../middlewares/authMiddleware');

// @route   GET api/org/me
// @desc    Get logged in organization profile
// @access  Private
router.get('/me', authMiddleware, getMeOrg);

// @route   PUT api/org/me
// @desc    Update logged in organization profile
// @access  Private
router.put('/me', authMiddleware, updateMeOrg);

module.exports = router;