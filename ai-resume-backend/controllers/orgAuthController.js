// controllers/orgAuthController.js
const Organization = require('../models/Organization');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

// @desc    Register a new organization
// @route   POST /api/org-auth/register
exports.registerOrg = async (req, res) => {
  const { orgName, email, password } = req.body;

  try {
    // 1. Check if organization already exists
    let org = await Organization.findOne({ email });
    if (org) {
      return res.status(400).json({ msg: 'Organization already exists' });
    }

    // 2. Create a new organization instance
    org = new Organization({
      orgName,
      email,
      password,
    });

    // 3. Hash the password
    const salt = await bcrypt.genSalt(10);
    org.password = await bcrypt.hash(password, salt);

    // 4. Save organization to database
    await org.save();

    // 5. Create and return a JSON Web Token (JWT)
    const payload = {
      user: {
        id: org.id, // Use org.id here
      },
    };

    jwt.sign(
      payload,
      process.env.JWT_SECRET,
      { expiresIn: '5h' },
      (err, token) => {
        if (err) throw err;
        res.json({ token });
      }
    );
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server error');
  }
};

// @desc    Authenticate organization & get token (Login)
// @route   POST /api/org-auth/login
exports.loginOrg = async (req, res) => {
  const { email, password } = req.body;

  try {
    // 1. Check if organization exists
    let org = await Organization.findOne({ email });
    if (!org) {
      return res.status(400).json({ msg: 'Invalid Credentials' });
    }

    // 2. Compare entered password with the stored hashed password
    const isMatch = await bcrypt.compare(password, org.password);
    if (!isMatch) {
      return res.status(400).json({ msg: 'Invalid Credentials' });
    }

    // 3. Create and return JWT
    const payload = {
      user: {
        id: org.id,
      },
    };

    jwt.sign(
      payload,
      process.env.JWT_SECRET,
      { expiresIn: '5h' },
      (err, token) => {
        if (err) throw err;
        res.json({ token });
      }
    );
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server error');
  }
};