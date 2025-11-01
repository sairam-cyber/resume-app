// controllers/resumeController.js
const { generateText } = require('../services/geminiService');
const User = require('../models/User');
const Resume = require('../models/Resume');
// --- MODIFIED IMPORTS ---
const { createTypstMarkupFromTemplate, compileTypst } = require('../services/typstService'); // <-- Use the new function
const { uploadToCloudinary } = require('../services/cloudinaryService');
const fs = require('fs');

// --- HELPER: Define common questions ---
const commonQuestions = [
  { key: 'name', question: "Let's start! What is your full name?" },
  { key: 'trade', question: "What is your trade or professional title? (e.g., 'Licensed Master Electrician', 'Heavy Equipment Operator')" },
  { key: 'phone', question: 'What is your phone number?' },
  { key: 'email', question: 'What is your email address?' },
  { key: 'location', question: 'What is your location? (e.g., "Houston, TX")' },
  { key: 'license', question: 'What is your primary license, if any? (e.g., "CDL Class A", "TX Master Electrician #ME-87654"). Type "skip" if none.' },
  { key: 'summary', question: 'Write a 2-3 sentence professional summary about yourself.' },
  { key: 'technical_skills', question: 'List your technical skills, separated by commas. (e.g., "MIG Welding, Blueprint Reading, Panel Upgrades")' },
  { key: 'safety_certs', question: 'List your safety certifications, separated by commas. (e.g., "OSHA 30-Hour, First Aid/CPR")' },
  
  // Experience 1
  { key: 'exp1_title', question: 'Let\'s add your most recent job. What was your position/title?' },
  { key: 'exp1_company', question: 'What was the company\'s name?' },
  { key: 'exp1_location', question: 'Where was it located? (e.g., "Houston, TX")' },
  { key: 'exp1_dates', question: 'When did you work there? (e.g., "June 2019 - Present")' },
  { key: 'exp1_responsibilities', question: 'List your key responsibilities or achievements, separated by commas.' },

  // Experience 2
  { key: 'exp2_title', question: 'Now, let\'s add your previous job. What was the position/title? (Type "skip" to move on)' },
  { key: 'exp2_company', question: 'What was the company\'s name?' },
  { key: 'exp2_location', question: 'Where was it located?' },
  { key: 'exp2_dates', question: 'When did you work there? (e.g., "March 2016 - May 2019")' },
  { key: 'exp2_responsibilities', question: 'List your key responsibilities, separated by commas.' },

  // Certifications
  { key: 'cert1_name', question: 'Let\'s list some detailed certifications. What is the name of a certification? (Type "skip" to move on)' },
  { key: 'cert1_issuer', question: 'Who issued this certification? (e.g., "Texas Dept. of Licensing")' },
  { key: 'cert1_date', question: 'What was the date issued? (e.g., "2019")' },
  { key: 'cert2_name', question: 'What is the name of a second certification? (Type "skip" to move on)' },
  { key: 'cert2_issuer', question: 'Who issued this certification?' },
  { key: 'cert2_date', question: 'What was the date issued?' },

  // Education
  { key: 'edu1_degree', question: 'Now for your education. What was your degree or diploma? (e.g., "Electrical Technology Diploma")' },
  { key: 'edu1_institution', question: 'What was the school or institution\'s name?' },
  { key: 'edu1_location', question: 'Where was it located?' },
  { key: 'edu1_year', question: 'What year did you graduate? (e.g., "2015")' },
  { key: 'edu2_degree', question: 'What is your second degree or program? (e.g., "4-Year Apprenticeship Program"). Type "skip" to move on.' },
  { key: 'edu2_institution', question: 'What was the institution\'s name?' },
  { key: 'edu2_location', question: 'Where was it located?' },
  { key: 'edu2_year', question: 'What year did you complete it?' },

  // Final Sections
  { key: 'safety_record', question: 'What is your safety record? (e.g., "8 years with ZERO lost-time incidents"). Type "skip" if none.' },
  { key: 'achievements', question: 'Finally, list any key achievements, separated by commas. (e.g., "Awarded \'Electrician of the Year\'"). Type "skip" if none.' },
];

// --- FLOWS FOR EACH TEMPLATE ---
// All flows will use the common questions for consistency.
// Specific templates (like Professional) will have extra questions appended.

const modernFlow = [...commonQuestions];
const classicFlow = [...commonQuestions];
const simpleFlow = [...commonQuestions];
const boldFlow = [...commonQuestions];
const creativeFlow = [...commonQuestions];

// Professional template has 'linkedin'
const professionalFlow = [
  ...commonQuestions,
  { key: 'linkedin', question: 'What is your LinkedIn profile URL? (e.g., "linkedin.com/in/yourname"). Type "skip" if none.' }
];

function getQuestionFlow(templateName) {
  switch (templateName) {
    case 'Modern':
      return modernFlow;
    case 'Classic':
      return classicFlow;
    case 'Professional':
      return professionalFlow;
    case 'Simple':
      return simpleFlow;
    case 'Bold':
      return boldFlow;
    case 'Creative':
      return creativeFlow;
    default:
      console.warn(`No specific flow for ${templateName}, using 'Simple'.`);
      return simpleFlow;
  }
}
// --- END: Question flow logic ---


// @desc    Start a new resume, get back the first question
// @route   POST api/resume/start
exports.startResume = async (req, res) => {
  const { template } = req.body;

  try {
    const questions = getQuestionFlow(template);
    
    // Create a new resume document to track the conversation
    const newResume = new Resume({
      user: req.user.id,
      template: template,
      resumeData: {
        'questionIndex': '0', // Start at the first question
      },
    });
    
    await newResume.save();

    res.json({
      resumeId: newResume._id,
      question: questions[0].question,
    });
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
};

// @desc    Submit an answer and get the next question
// @route   POST api/resume/next
exports.askNextQuestion = async (req, res) => {
  const { resumeId, answer } = req.body;

  try {
    const resume = await Resume.findById(resumeId);
    if (!resume) {
      return res.status(404).json({ msg: 'Resume not found' });
    }
    if (resume.user.toString() !== req.user.id) {
      return res.status(401).json({ msg: 'User not authorized' });
    }

    const questions = getQuestionFlow(resume.template);
    let index = parseInt(resume.resumeData.get('questionIndex') || '0');

    // Save the answer to the *previous* question
    const currentKey = questions[index].key;
    if (answer.toLowerCase() !== 'skip') {
      resume.resumeData.set(currentKey, answer);
    }

    // --- Skip logic for optional questions ---
    // If the user skips an optional block (e.g., exp2_title), skip all related questions
    if (answer.toLowerCase() === 'skip' && currentKey === 'exp2_title') {
      index = questions.findIndex(q => q.key === 'cert1_name') - 1; // Find index of next section
    } else if (answer.toLowerCase() === 'skip' && currentKey === 'cert1_name') {
      index = questions.findIndex(q => q.key === 'edu1_degree') - 1;
    } else if (answer.toLowerCase() === 'skip' && currentKey === 'cert2_name') {
      index = questions.findIndex(q => q.key === 'edu1_degree') - 1;
    } else if (answer.toLowerCase() === 'skip' && currentKey === 'edu2_degree') {
      index = questions.findIndex(q => q.key === 'safety_record') - 1;
    }
    // --- End skip logic ---

    // Move to the next question
    index++;
    resume.resumeData.set('questionIndex', index.toString());
    await resume.save();

    // Check if conversation is complete
    if (index >= questions.length) {
      return res.json({
        question: 'Great! Your profile is complete. You can now generate your PDF resume.',
        isComplete: true,
      });
    }

    // Send the next question
    res.json({
      question: questions[index].question,
      isComplete: false,
    });

  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
};


// @desc    Generate, upload, and save the resume PDF
// @route   POST /api/resume/generate-pdf
exports.generatePdf = async (req, res) => {
  const { resumeId } = req.body;

  if (!resumeId) {
    return res.status(400).json({ msg: 'Resume ID is required' });
  }

  try {
    // 1. Find the resume and user
    const resume = await Resume.findById(resumeId);
    const user = await User.findById(req.user.id); // <-- Get user
    if (!resume) {
      return res.status(404).json({ msg: 'Resume not found' });
    }
    if (resume.user.toString() !== req.user.id) {
      return res.status(401).json({ msg: 'User not authorized' });
    }

    // 2. Get language
    const language = user.preferredLanguage || 'en';

    // 3. --- THIS IS THE KEY CHANGE ---
    // Generate Typst markup from the *template* and the saved chat data
    let typstMarkup;
    try {
      // This function now generates the *full* .typ file content
      typstMarkup = createTypstMarkupFromTemplate(resume.resumeData, resume.template);
    } catch (e) {
      console.error(e.message);
      return res.status(500).json({ msg: e.message }); // Send template-related errors to client
    }
    // --- END OF TRY...CATCH ---

    // 4. Compile the Typst file to PDF
    const pdfFilePath = await compileTypst(typstMarkup, resumeId);

    // 5. Upload the generated PDF to Cloudinary
    const uploadResult = await uploadToCloudinary(pdfFilePath, `resume_${resumeId}`);

    // 6. Clean up the temp PDF file
    if (fs.existsSync(pdfFilePath)) {
      fs.unlinkSync(pdfFilePath);
    }

    // 7. Save the secure URL from Cloudinary to the resume document
    resume.pdfUrl = uploadResult.secure_url;
    await resume.save();

    // 8. Return the final resume object with the PDF URL
    res.json({
      message: 'Resume generated successfully!',
      resume: resume,
    });
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
};