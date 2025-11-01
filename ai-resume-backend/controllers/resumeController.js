// controllers/resumeController.js
const { generateText } = require('../services/geminiService');
const User = require('../models/User');
const Resume = require('../models/Resume');
// --- MODIFIED IMPORTS ---
const { generateBlueCollarPdf } = require('../services/pdfService'); // <-- USE NEW PDF SERVICE
const { uploadToCloudinary } = require('../services/cloudinaryService');
const { getQuestionsByLanguage, getCompletionMessage, getLinkedInQuestion } = require('../translations/resumeQuestions');
const fs = require('fs');

// --- HELPER: Get question flow (UNCHANGED) ---
function getQuestionFlow(templateName, language = 'en') {
  // ... (this function is unchanged)
  const commonQuestions = getQuestionsByLanguage(language);
  if (templateName === 'Professional') {
    return [...commonQuestions, getLinkedInQuestion(language)];
  }
  return commonQuestions;
}

// @desc    Start a new resume, get back the first question (UNCHANGED)
// @route   POST api/resume/start
exports.startResume = async (req, res) => {
  // ... (this function is unchanged)
  const { template, language } = req.body;
  const userLanguage = language || 'en';
  try {
    const questions = getQuestionFlow(template, userLanguage);
    const newResume = new Resume({
      user: req.user.id,
      template: template,
      resumeData: {
        'questionIndex': '0',
        'language': userLanguage,
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

// @desc    Submit an answer and get the next question (UNCHANGED)
// @route   POST api/resume/next
exports.askNextQuestion = async (req, res) => {
  // ... (this function is unchanged)
  const { resumeId, answer } = req.body;
  try {
    const resume = await Resume.findById(resumeId);
    if (!resume) {
      return res.status(404).json({ msg: 'Resume not found' });
    }
    if (resume.user.toString() !== req.user.id) {
      return res.status(401).json({ msg: 'User not authorized' });
    }

    const userLanguage = resume.resumeData.get('language') || 'en';
    const questions = getQuestionFlow(resume.template, userLanguage);
    let index = parseInt(resume.resumeData.get('questionIndex') || '0');

    const currentKey = questions[index].key;
    if (answer.toLowerCase() !== 'skip') {
      resume.resumeData.set(currentKey, answer);
    }

    // Skip logic (unchanged)
    if (answer.toLowerCase() === 'skip' && currentKey === 'exp2_title') {
      index = questions.findIndex(q => q.key === 'cert1_name') - 1;
    } else if (answer.toLowerCase() === 'skip' && currentKey === 'cert1_name') {
      index = questions.findIndex(q => q.key === 'edu1_degree') - 1;
    } else if (answer.toLowerCase() === 'skip' && currentKey === 'cert2_name') {
      index = questions.findIndex(q => q.key === 'edu1_degree') - 1;
    } else if (answer.toLowerCase() === 'skip' && currentKey === 'edu2_degree') {
      index = questions.findIndex(q => q.key === 'safety_record') - 1;
    }

    index++;
    resume.resumeData.set('questionIndex', index.toString());
    await resume.save();

    if (index >= questions.length) {
      return res.json({
        question: getCompletionMessage(userLanguage),
        isComplete: true,
      });
    }

    res.json({
      question: questions[index].question,
      isComplete: false,
    });
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
};


// @desc    Generate, upload, and save the resume PDF (UNCHANGED)
// @route   POST /api/resume/generate-pdf
exports.generatePdf = async (req, res) => {
  // ... (this function is unchanged from our previous step)
  const { resumeId } = req.body;
  if (!resumeId) {
    return res.status(400).json({ msg: 'Resume ID is required' });
  }

  try {
    // 1. Find the resume and user
    const resume = await Resume.findById(resumeId);
    const user = await User.findById(req.user.id);
    if (!resume) {
      return res.status(404).json({ msg: 'Resume not found' });
    }
    if (resume.user.toString() !== req.user.id) {
      return res.status(401).json({ msg: 'User not authorized' });
    }

    // 2. Generate PDF using our new service
    let pdfFilePath;
    try {
      pdfFilePath = await generateBlueCollarPdf(resume.resumeData, user);
    } catch (e) {
      console.error('PDF generation error:', e.message);
      return res.status(500).json({ msg: `PDF Generation Failed: ${e.message}` });
    }

    // 3. Upload the generated PDF to Cloudinary
    const uploadResult = await uploadToCloudinary(pdfFilePath, `resume_${resumeId}`);

    // 4. Clean up the temp PDF file
    if (fs.existsSync(pdfFilePath)) {
      fs.unlinkSync(pdfFilePath);
    }

    // 5. Save the secure URL from Cloudinary
    resume.pdfUrl = uploadResult.secure_url;
    await resume.save();

    // 6. Return the final resume object
    res.json({
      message: 'Resume generated successfully!',
      resume: resume,
    });
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
};

// --- *** THIS IS THE MAIN CHANGE *** ---
// @desc    Parse transcribed text into structured resume JSON
// @route   POST /api/resume/parse-voice
exports.parseVoiceResume = async (req, res) => {
  const { transcribedText, language } = req.body;
  const userLanguage = language || 'en';

  if (!transcribedText) {
    return res.status(400).json({ msg: 'Transcribed text is required.' });
  }

  const langName = userLanguage === 'hi' ? 'Hindi' : userLanguage === 'or' ? 'Odia' : 'English';

  // This new prompt tells Gemini to *act as a resume writer*
  const prompt = `
  You are an expert AI resume builder for blue-collar professionals (like Drivers, Plumbers, Electricians). A user has provided a voice transcript in ${langName}.
  Your task is to act as a resume writer. Analyze the transcript and generate professional resume content for them.
  Return the resume content as a single, valid JSON object.
  The JSON keys must be: "fullName", "jobTitle", "phone", "email", "location", "summary", and "skills".

  - "fullName", "phone", "email", "location": Extract these directly if mentioned.
  - "jobTitle": Extract this (e.g., "Driver", "Plumber"). If not specified, infer it from the context.
  - "summary": **Write a professional summary** (2-3 sentences) based on their experience, skills, and qualities mentioned in the transcript.
  - "skills": **Generate a comma-separated list** of relevant technical and soft skills based on their job and description.

  If any information is not found in the transcript, return an empty string "" for that key.
  Do NOT include any text before or after the JSON object.

  Here is the transcript:
  ---
  ${transcribedText}
  ---

  Return only the valid JSON object.
  `;

  try {
    const jsonText = await generateText(prompt);
    
    // Clean up the response from Gemini to ensure it's valid JSON
    let cleanedText = jsonText
      .replace(/```json/g, '')
      .replace(/```/g, '')
      .trim();
      
    let parsedData;
    try {
      parsedData = JSON.parse(cleanedText);
    } catch {
      // Fallback: try to find the JSON object if Gemini added extra text
      const start = cleanedText.indexOf('{');
      const end = cleanedText.lastIndexOf('}');
      if (start !== -1 && end !== -1) {
        parsedData = JSON.parse(cleanedText.slice(start, end + 1));
      } else {
        throw new Error('Failed to parse AI JSON response.');
      }
    }
    
    // Send the AI-generated JSON back to the app
    res.json(parsedData);

  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server error while parsing resume text.');
  }
};