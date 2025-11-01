// middlewares/ploadMiddleware.js
const multer = require('multer');
const path = require('path');
const fs = require('fs'); // <-- 1. ADD THIS

// --- 2. ADD THIS: Define the temp directory path ---
const tempDir = path.join(__dirname, '..', 'temp');

// Set up storage engine
const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    // --- 3. ADD THIS: Check if tempDir exists, create if not ---
    if (!fs.existsSync(tempDir)) {
      fs.mkdirSync(tempDir, { recursive: true });
    }
    // --- END OF ADDITION ---

    cb(null, tempDir); // <-- 4. Use the full path variable
  },
  filename: function (req, file, cb) {
    // Create a unique filename to avoid conflicts
    cb(null, file.fieldname + '-' + Date.now() + path.extname(file.originalname));
  },
});

// Initialize upload
const upload = multer({
  storage: storage,
  limits: { fileSize: 10000000 }, // Limit file size to 10MB
  fileFilter: function (req, file, cb) {
    checkFileType(file, cb);
  },
}).single('resume'); // 'resume' is the field name the frontend will use for the file

// Check File Type
function checkFileType(file, cb) {
  // Allowed ext
  const filetypes = /pdf/;
  // Check ext
  const extname = filetypes.test(path.extname(file.originalname).toLowerCase());
  // Check mime
  const mimetype = filetypes.test(file.mimetype);

  if (mimetype && extname) {
    return cb(null, true);
  } else {
    cb('Error: PDFs Only!');
  }
}

module.exports = upload;