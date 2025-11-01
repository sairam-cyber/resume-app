// controllers/jobController.js
const Job = require('../models/Job');
const Application = require('../models/Application'); // <-- 1. ADD THIS
const User = require('../models/User'); // <-- 2. ADD THIS
const Organization = require('../models/Organization'); // <-- 3. ADD THIS

// @desc    Create a new job
// @route   POST /api/job
// @access  Private (Organization)
exports.createJob = async (req, res) => {
  const { role, location, salary, openings, description } = req.body;

  try {
    const newJob = new Job({
      organization: req.user.id, // from authMiddleware
      role,
      location,
      salary,
      openings,
      description,
    });

    const job = await newJob.save();
    res.json(job);
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
};

// @desc    Get all jobs for the logged-in organization
// @route   GET /api/job/my-jobs
// @access  Private (Organization)
exports.getMyJobs = async (req, res) => {
  try {
    const jobs = await Job.find({ organization: req.user.id }).sort({ createdAt: -1 });
    res.json(jobs);
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
};

// @desc    Get all jobs from all organizations
// @route   GET /api/job
// @access  Private (User)
exports.getAllJobs = async (req, res) => {
  try {
    // Populate 'organization' field, selecting only 'orgName'
    const jobs = await Job.find().populate('organization', 'orgName').sort({ createdAt: -1 });
    res.json(jobs);
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
};

// --- 4. MODIFY THIS FUNCTION ---
// @desc    Apply for a job
// @route   POST /api/job/apply/:jobId
// @access  Private (User)
exports.applyForJob = async (req, res) => {
  try {
    const job = await Job.findById(req.params.jobId);
    if (!job) {
      return res.status(404).json({ msg: 'Job not found' });
    }
    
    // Check if user already applied
    const existingApplication = await Application.findOne({
      job: req.params.jobId,
      user: req.user.id,
    });

    if (existingApplication) {
      return res.status(400).json({ msg: 'You have already applied for this job' });
    }

    // Create a new 'Application' document
    const newApplication = new Application({
      job: req.params.jobId,
      user: req.user.id,
      organization: job.organization, // Get org ID from the job
    });

    await newApplication.save();
    
    res.json({ msg: 'Application submitted successfully' });

  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
};

// --- 5. ADD THIS NEW FUNCTION ---
// @desc    Get all applicants for a specific job
// @route   GET /api/job/applicants/:jobId
// @access  Private (Organization)
exports.getApplicantsForJob = async (req, res) => {
  try {
    // 1. Find applications for the job, populating the 'user' details
    const applications = await Application.find({ job: req.params.jobId })
      .populate('user', 'fullName phoneNumber'); // <-- Select what user details you need

    if (!applications) {
      return res.status(404).json({ msg: 'No applications found for this job' });
    }

    // 2. Check if the logged-in org owns this job (security check)
    if (applications.length > 0) {
      const job = await Job.findById(req.params.jobId);
      if (job.organization.toString() !== req.user.id) {
         return res.status(401).json({ msg: 'Not authorized' });
      }
    }
    
    res.json(applications);
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
};

// --- 6. ADD THIS NEW FUNCTION ---
// @desc    Accept an applicant and send notification
// @route   POST /api/job/accept-applicant
// @access  Private (Organization)
exports.acceptApplicant = async (req, res) => {
  const { applicationId } = req.body;

  // Set up Twilio (you must install: npm install twilio)
  // Add TWILIO_ACCOUNT_SID, TWILIO_AUTH_TOKEN, and TWILIO_WHATSAPP_SENDER to your .env file
  const twilio = require('twilio');
  const twilioClient = twilio(process.env.TWILIO_ACCOUNT_SID, process.env.TWILIO_AUTH_TOKEN);
  const fromWhatsAppNumber = process.env.TWILIO_WHATSAPP_SENDER; // e.g., 'whatsapp:+14155238886'
  
  try {
    // 1. Find the application and populate all details needed for the message
    let application = await Application.findById(applicationId)
      .populate('user', 'fullName phoneNumber')
      .populate('job', 'role location')
      .populate('organization', 'orgName');

    if (!application) {
      return res.status(404).json({ msg: 'Application not found' });
    }

    // 2. Security check: does this org own this application?
    if (application.organization._id.toString() !== req.user.id) {
      return res.status(401).json({ msg: 'Not authorized' });
    }

    // 3. Update application status
    application.status = 'Selected';
    await application.save();

    // 4. Send the notification
    const user = application.user;
    const job = application.job;
    const org = application.organization;

    // Format the phone number for WhatsApp (e.g., 'whatsapp:+919876543210')
    // This assumes user.phoneNumber is stored with country code like +91
    const toWhatsAppNumber = `whatsapp:${user.phoneNumber}`;

    const messageBody = `Congratulations ${user.fullName}! You have been selected for the ${job.role} position in ${job.location} by ${org.orgName}.`;

    // Use Twilio to send WhatsApp message
    // NOTE: This will fail if the user has not opted-in to your Twilio WhatsApp number!
    await twilioClient.messages.create({
      body: messageBody,
      from: fromWhatsAppNumber,
      to: toWhatsAppNumber
    });

    res.json({ msg: 'Candidate accepted and notified via WhatsApp!' });

  } catch (err) {
    console.error(err.message);
    // Handle common Twilio error if user has not opted-in
    if (err.code === 21614) { 
        return res.status(500).json({ msg: 'Notification failed: User has not opted-in to WhatsApp messages.' });
    }
    res.status(500).send('Server Error');
  }
};