// routes/atsRoutes.js
const express = require('express');
const router = express.Router();
const { checkAtsScore, editResumeWithAI, generateEditedPdf } = require('../controllers/atsController');
const authMiddleware = require('../middlewares/authMiddleware');
const uploadMiddleware = require('../middlewares/ploadMiddleware'); // Your 'ploadMiddleware.js'

// @route   POST api/ats/check
// @desc    Upload a resume, get its ATS score, and save it
// @access  Private
router.post('/check', [authMiddleware, uploadMiddleware], checkAtsScore);

// @route   POST api/ats/edit
// @desc    (This is the old one-shot rewrite, you can keep or remove it)
// @access  Private
router.post('/edit', authMiddleware, editResumeWithAI);

// --- NEW ROUTE ---
// @route   POST api/ats/generate-edited-pdf
// @desc    Generate the final edited PDF after the chat flow
// @access  Private
router.post('/generate-edited-pdf', authMiddleware, generateEditedPdf);

module.exports = router;