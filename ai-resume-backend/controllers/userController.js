// controllers/userController.js
const User = require('../models/User');
const Resume = require('../models/Resume'); // <-- ADDED

// @desc    Get logged in user's profile
// @route   GET /api/user/me
// @access  Private
exports.getMe = async (req, res) => {
  try {
    const user = await User.findById(req.user.id).select('-password');
    if (!user) {
      return res.status(404).json({ msg: 'User not found' });
    }
    res.json(user);
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
};

// @desc    Update logged in user's profile
// @route   PUT /api/user/me
// @access  Private
exports.updateMe = async (req, res) => {
  const { fullName, phoneNumber } = req.body;

  const profileFields = {};
  if (fullName) profileFields.fullName = fullName;
  if (phoneNumber) profileFields.phoneNumber = phoneNumber;

  try {
    let user = await User.findById(req.user.id);
    if (!user) {
      return res.status(404).json({ msg: 'User not found' });
    }

    user = await User.findByIdAndUpdate(
      req.user.id,
      { $set: profileFields },
      { new: true }
    ).select('-password');

    res.json(user);
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
};

// @desc    Get all resumes for the logged-in user
// @route   GET /api/user/resumes
// @access  Private
exports.getMyResumes = async (req, res) => {
  try {
    const resumes = await Resume.find({ user: req.user.id }).sort({ createdAt: -1 });
    res.json(resumes);
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
};


// @desc    Update user's preferred language
// @route   PUT /api/user/language
exports.updateLanguage = async (req, res) => {
  const { languageCode } = req.body; 

  if (!languageCode) {
    return res.status(400).json({ msg: 'Language code is required' });
  }

  try {
    const user = await User.findByIdAndUpdate(
      req.user.id, 
      { preferredLanguage: languageCode },
      { new: true } 
    ).select('-password'); 

    if (!user) {
      return res.status(404).json({ msg: 'User not found' });
    }

    res.json({ msg: 'Language preference updated successfully', user });
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
};