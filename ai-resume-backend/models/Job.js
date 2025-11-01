// models/Job.js
const mongoose = require('mongoose');

const JobSchema = new mongoose.Schema({
  organization: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Organization',
    required: true,
  },
  role: {
    type: String,
    required: true,
  },
  location: {
    type: String,
    required: true,
  },
  salary: {
    type: String, // e.g., "₹15,000 - ₹20,000"
    required: true,
  },
  openings: {
    type: String, // e.g., "5"
    required: true,
  },
  description: {
    type: String,
    default: 'No description provided.',
  },
  createdAt: {
    type: Date,
    default: Date.now,
  },
});

module.exports = mongoose.model('Job', JobSchema);