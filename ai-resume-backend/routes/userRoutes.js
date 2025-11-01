// routes/userRoutes.js
const express = require('express');
const router = express.Router();
const { updateLanguage, getMe, updateMe, getMyResumes } = require('../controllers/userController'); // <-- UPDATED
const authMiddleware = require('../middlewares/authMiddleware');

// @route   GET api/user/me
// @desc    Get logged in user profile
// @access  Private (requires token)
router.get('/me', authMiddleware, getMe);

// @route   PUT api/user/me
// @desc    Update logged in user profile
// @access  Private (requires token)
router.put('/me', authMiddleware, updateMe); // <-- ADDED

// @route   GET api/user/resumes
// @desc    Get all resumes for logged in user
// @access  Private (requires token)
router.get('/resumes', authMiddleware, getMyResumes); // <-- ADDED

// @route   PUT api/user/language
// @desc    Update user preferred language
// @access  Private (requires token)
router.put('/language', authMiddleware, updateLanguage);

module.exports = router;