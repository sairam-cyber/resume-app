// routes/jobRoutes.js
const express = require('express');
const router = express.Router();
const { 
  createJob, 
  getMyJobs, 
  getAllJobs, 
  applyForJob,
  getApplicantsForJob,  // <-- 1. ADD THIS
  acceptApplicant       // <-- 2. ADD THIS
} = require('../controllers/jobController');
const authMiddleware = require('../middlewares/authMiddleware');

// @route   POST api/job
// @desc    Create a new job (Org only)
// @access  Private
router.post('/', authMiddleware, createJob);

// @route   GET api/job/my-jobs
// @desc    Get an organization's own jobs (Org only)
// @access  Private
router.get('/my-jobs', authMiddleware, getMyJobs);

// @route   GET api/job
// @desc    Get all jobs (User only)
// @access  Private
router.get('/', authMiddleware, getAllJobs);

// @route   POST api/job/apply/:jobId
// @desc    Apply for a job (User only)
// @access  Private
router.post('/apply/:jobId', authMiddleware, applyForJob);

// --- 3. ADD THESE NEW ROUTES ---

// @route   GET api/job/applicants/:jobId
// @desc    Get all applicants for a job (Org only)
// @access  Private
router.get('/applicants/:jobId', authMiddleware, getApplicantsForJob);

// @route   POST api/job/accept-applicant
// @desc    Accept an applicant (Org only)
// @access  Private
router.post('/accept-applicant', authMiddleware, acceptApplicant);

// --- END OF ADDITION ---

module.exports = router;