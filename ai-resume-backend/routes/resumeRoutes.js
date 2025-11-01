const express = require('express');
const router = express.Router();
const { startResume, askNextQuestion, generatePdf } = require('../controllers/resumeController');
const authMiddleware = require('../middlewares/authMiddleware');

// @route   POST api/resume/start
// @desc    Start a new resume, get back the first question
// @access  Private
router.post('/start', authMiddleware, startResume);

// @route   POST api/resume/next
// @desc    Submit an answer and get the next question
// @access  Private
router.post('/next', authMiddleware, askNextQuestion);

// @route   POST api/resume/generate-pdf
// @desc    Generate the final resume PDF
// @access  Private
router.post('/generate-pdf', authMiddleware, generatePdf);

module.exports = router;