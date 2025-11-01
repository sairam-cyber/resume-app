// models/Resume.js
const mongoose = require('mongoose');

const ResumeSchema = new mongoose.Schema({
  user: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
  },
  template: {
    type: String, // e.g., 'Modern', 'Classic', or 'Uploaded'
    required: true,
  },
  
  // --- For Chat-Built Resumes ---
  resumeData: {
    type: Map,
    of: String,
    default: {},
  },

  // --- For ATS-Checked Resumes ---
  originalResumeText: { // Text extracted from the user's PDF
    type: String,
  },
  atsScore: {
    type: Number,
  },
  atsSuggestions: { // The JSON suggestions from Gemini
    type: Object,
  },
  editedPdfUrl: { // The URL of the *new* PDF after AI editing
    type: String,
  },

  // --- Final PDF URL ---
  // This can be from the chat-built flow OR the edited ATS flow
  pdfUrl: {
    type: String,
  },
  createdAt: {
    type: Date,
    default: Date.now,
  },
});

module.exports = mongoose.model('Resume', ResumeSchema);