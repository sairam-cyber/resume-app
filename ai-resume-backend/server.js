// server.js
const express = require('express');
const dotenv = require('dotenv');
const connectDB = require('./config/db');
const cors = require('cors');

// Load env vars
dotenv.config();

// Connect to Database
connectDB();

const app = express();

// Enable CORS
app.use(cors());

// Body Parser Middleware
app.use(express.json());

// Define Routes
app.use('/api/auth', require('./routes/authRoutes'));
app.use('/api/org-auth', require('./routes/orgAuthRoutes')); 
app.use('/api/user', require('./routes/userRoutes'));
app.use('/api/resume', require('./routes/resumeRoutes'));
app.use('/api/ats', require('./routes/atsRoutes'));
app.use('/api/org', require('./routes/orgRoutes')); // <-- ADDED THIS LINE
app.use('/api/job', require('./routes/jobRoutes')); // <-- ADDED THIS LINE

const PORT = process.env.PORT || 5000;

app.listen(PORT, () => console.log(`Server started on port ${PORT}`));