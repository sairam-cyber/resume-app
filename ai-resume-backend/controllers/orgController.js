// controllers/orgController.js
const Organization = require('../models/Organization');

// @desc    Get logged in organization's profile
// @route   GET /api/org/me
// @access  Private
exports.getMeOrg = async (req, res) => {
  try {
    // req.user.id is attached by authMiddleware (even for orgs)
    const org = await Organization.findById(req.user.id).select('-password');
    if (!org) {
      return res.status(404).json({ msg: 'Organization not found' });
    }
    res.json(org);
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
};

// @desc    Update logged in organization's profile
// @route   PUT /api/org/me
// @access  Private
exports.updateMeOrg = async (req, res) => {
  const { orgName, email } = req.body;

  const profileFields = {};
  if (orgName) profileFields.orgName = orgName;
  if (email) profileFields.email = email;

  try {
    let org = await Organization.findById(req.user.id);
    if (!org) {
      return res.status(404).json({ msg: 'Organization not found' });
    }

    org = await Organization.findByIdAndUpdate(
      req.user.id,
      { $set: profileFields },
      { new: true }
    ).select('-password');

    res.json(org);
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
};