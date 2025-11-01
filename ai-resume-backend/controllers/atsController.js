// controllers/atsController.js
const fs = require('fs');
const { PDFParse } = require('pdf-parse'); // v2 class export [web:7]

const { generateText } = require('../services/geminiService');
const { compileTypst } = require('../services/typstService');
const { uploadToCloudinary } = require('../services/cloudinaryService');
const Resume = require('../models/Resume');
const User = require('../models/User');

exports.checkAtsScore = async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ msg: 'No resume file uploaded.' });
    }

    // Support memoryStorage and diskStorage
    const dataBuffer = req.file.buffer
      ? req.file.buffer
      : fs.readFileSync(req.file.path);

    // v2 usage: construct the parser and extract text
    const parser = new PDFParse({ data: dataBuffer }); // v2 accepts { data: Buffer } [web:7]
    const parsed = await parser.getText(); // returns { text, total, ... } [web:7]
    await parser.destroy(); // free resources [web:7]
    const resumeText = parsed.text || ''; // safe fallback [web:7]

    // Clean temp file if present
    try {
      if (req.file.path && fs.existsSync(req.file.path)) fs.unlinkSync(req.file.path);
    } catch (_) {}

    const prompt = `
Analyze the following resume text for its compatibility with an Applicant Tracking System (ATS). Provide a detailed analysis in a valid JSON object.
The JSON object must have three keys:
1. "atsScore": An integer between 0 and 100.
2. "scoreMessage": A brief, encouraging message.
3. "suggestions": An array of 3 specific, actionable suggestions for improvement. Each object in the array should have three keys: "icon", "title", and "subtitle".
Here is the resume text:

---
${resumeText}
---

Provide only the JSON object as your response.
`;

    const analysisText = await generateText(prompt);

    // Clean code fences safely (avoid fragile regex)
    let cleanedText = analysisText
      .replaceAll('```', '')
      .replaceAll('```', '')
      .trim();

    // Parse JSON with fallback extraction
    let parsedAnalysis;
    try {
      parsedAnalysis = JSON.parse(cleanedText);
    } catch {
      const start = analysisText.indexOf('{');
      const end = analysisText.lastIndexOf('}');
      if (start !== -1 && end !== -1) {
        parsedAnalysis = JSON.parse(analysisText.slice(start, end + 1));
      } else {
        console.error('Failed to parse AI JSON response for ATS check:', analysisText);
        return res.status(500).send('Error processing AI analysis.');
      }
    }

    const { atsScore, suggestions, scoreMessage } = parsedAnalysis;

    const newResume = new Resume({
      user: req.user.id,
      template: 'Uploaded',
      originalResumeText: resumeText,
      atsScore,
      atsSuggestions: suggestions,
    });
    await newResume.save();

    return res.json({
      resumeId: newResume._id,
      atsScore,
      scoreMessage,
      suggestions,
    });
  } catch (err) {
    console.error(err);
    try {
      if (req.file && req.file.path && fs.existsSync(req.file.path)) fs.unlinkSync(req.file.path);
    } catch (_) {}
    return res.status(500).send('Server Error');
  }
};



// @desc Generate final PDF after conversational editing
// @route POST /api/ats/generate-edited-pdf
exports.generateEditedPdf = async (req, res) => {
  try {
    const { resumeId, userAnswers } = req.body;
    if (!resumeId || !userAnswers) {
      return res.status(400).json({ msg: 'Resume ID and user answers are required.' });
    }

    const resume = await Resume.findById(resumeId);
    if (!resume) {
      return res.status(404).json({ msg: 'Resume not found' });
    }

    if (resume.user.toString() !== req.user.id) {
      return res.status(401).json({ msg: 'User not authorized' });
    }

    const user = await User.findById(req.user.id);
    const language =
      user.preferredLanguage === 'hi'
        ? 'Hindi'
        : user.preferredLanguage === 'or'
        ? 'Odia'
        : 'English';
    const langName = language === 'hi' ? 'Hindi' : language === 'or' ? 'Odia' : 'English';

    const prompt = `
You are an expert resume editor. Your task is to rewrite a user's resume by integrating their answers to specific suggestions.
The output MUST be a complete, valid Typst file.
The user's preferred language is ${langName} (language code: ${language}).
All resume section headings (e.g., "Work Experience", "Skills", "Education") MUST be in ${langName}.
The user's provided details (like company names, job titles, or their answers) should remain in the language they were written in.
Use the "Noto Sans" font, as it supports English, Hindi, and Odia.

Original Resume Text:
***
${resume.originalResumeText}
***

AI Suggestions that were given to the user:
***
${JSON.stringify(resume.atsSuggestions, null, 2)}
***

User's answers to these suggestions:
***
${JSON.stringify(userAnswers, null, 2)}
***

Instructions:
1. Read the original resume.
2. Read the suggestions and the user's corresponding answers.
3. Rewrite the entire resume, integrating the user's answers to improve the original text.
4. Format the entire rewritten resume as a single Typst file.
5. Start the Typst file with:
#set document(author: "User", title: "Resume")
#set text(font: "Noto Sans", lang: "${language}")
6. Ensure all section headings are translated to ${langName}.
Provide only the raw Typst code as your response. Do not include fences.
`;

    const typstMarkup = await generateText(prompt);
    const pdfFilePath = await compileTypst(typstMarkup, resumeId);
    const uploadResult = await uploadToCloudinary(pdfFilePath, `edited_${resumeId}`);

    try {
      if (fs.existsSync(pdfFilePath)) fs.unlinkSync(pdfFilePath);
    } catch (_) {}

    resume.editedPdfUrl = uploadResult.secure_url;
    resume.pdfUrl = uploadResult.secure_url;
    await resume.save();

    return res.json({
      message: 'Resume generated successfully!',
      resume,
    });
  } catch (err) {
    console.error(err);
    return res.status(500).send('Server Error');
  }
};

// @desc    Rewrite a resume with AI based on suggestions (One-shot)
// @route   POST /api/ats/edit
exports.editResumeWithAI = async (req, res) => {
  // This is your original function, unchanged.
  // ... (your existing code for this)
  const { resumeText, suggestions } = req.body;
  // ...
};


// --- NEW FUNCTION ---
// @desc    Generate final PDF after conversational editing
// @route   POST /api/ats/generate-edited-pdf
exports.generateEditedPdf = async (req, res) => {
  const { resumeId, userAnswers } = req.body; // userAnswers is the Map from the frontend

  if (!resumeId || !userAnswers) {
    return res.status(400).json({ msg: 'Resume ID and user answers are required.' });
  }

  try {
    // 1. Find the resume and the user
    const resume = await Resume.findById(resumeId);
    const user = await User.findById(req.user.id);

    if (!resume) {
      return res.status(404).json({ msg: 'Resume not found' });
    }
    if (resume.user.toString() !== req.user.id) {
      return res.status(401).json({ msg: 'User not authorized' });
    }

    // 2. Get user's preferred language
    const language = user.preferredLanguage === 'hi' ? 'Hindi' : user.preferredLanguage === 'or' ? 'Odia' : 'English';
    const langName = language === 'hi' ? 'Hindi' : language === 'or' ? 'Odia' : 'English';

    // 3. Craft the prompt for Gemini to generate a Typst file
    const prompt = `
      You are an expert resume editor. Your task is to rewrite a user's resume by integrating their answers to specific suggestions.
      The output MUST be a complete, valid Typst file.
      The user's preferred language is ${langName} (language code: ${language}).
      All resume section headings (e.g., "Work Experience", "Skills", "Education") MUST be in ${langName}.
      The user's provided details (like company names, job titles, or their answers) should remain in the language they were written in.
      Use the "Noto Sans" font, as it supports English, Hindi, and Odia.

      Original Resume Text:
      ---
      ${resume.originalResumeText}
      ---

      AI Suggestions that were given to the user:
      ---
      ${JSON.stringify(resume.atsSuggestions, null, 2)}
      ---

      User's answers to these suggestions:
      ---
      ${JSON.stringify(userAnswers, null, 2)}
      ---

      Instructions:
      1. Read the original resume.
      2. Read the suggestions and the user's corresponding answers.
      3. Rewrite the *entire* resume, integrating the user's answers to improve the original text.
      4. Format the *entire* rewritten resume as a single Typst file.
      5. Start the Typst file with:
         #set document(author: "User", title: "Resume")
         #set text(font: "Noto Sans", lang: "${language}")
      6. Ensure all section headings are translated to ${langName}.
      
      Provide *only* the raw Typst code as your response. Do not include \`\`\`typst or \`\`\`.
    `;

    // 4. Get the Typst markup from Gemini
    const typstMarkup = await generateText(prompt);

    // 5. Compile the Typst markup to PDF
    const pdfFilePath = await compileTypst(typstMarkup, resumeId);

    // 6. Upload the new PDF to Cloudinary
    const uploadResult = await uploadToCloudinary(pdfFilePath, `edited_${resumeId}`);
    
    // 7. Clean up the temp PDF file
    if (fs.existsSync(pdfFilePath)) {
      fs.unlinkSync(pdfFilePath);
    }

    // 8. Save the new URL to the resume document
    resume.editedPdfUrl = uploadResult.secure_url;
    resume.pdfUrl = uploadResult.secure_url; // Also update the main pdfUrl
    await resume.save();

    res.json({
      message: 'Resume generated successfully!',
      resume: resume, // Send the updated resume object back
    });

  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
};