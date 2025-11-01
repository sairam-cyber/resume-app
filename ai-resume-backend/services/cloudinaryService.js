// services/cloudinaryService.js
const cloudinary = require('cloudinary').v2;
const fs = require('fs');

// Configure Cloudinary with your credentials from .env
cloudinary.config({
  cloud_name: process.env.CLOUDINARY_CLOUD_NAME,
  api_key: process.env.CLOUDINARY_API_KEY,
  api_secret: process.env.CLOUDINARY_API_SECRET,
});

/**
 * Uploads a file to Cloudinary.
 * @param {string} localFilePath - The path to the temporary file on the server.
 * @param {string} publicId - The desired public ID (filename) for the file in Cloudinary.
 * @returns {Promise<object>} The Cloudinary upload result object.
 */
const uploadToCloudinary = (localFilePath, publicId) => {
  return new Promise((resolve, reject) => {
    cloudinary.uploader.upload(
      localFilePath,
      {
        public_id: publicId,
        resource_type: 'raw', // Use 'raw' for PDFs to avoid transformations
      },
      (error, result) => {
        if (error) {
          return reject(error);
        }
        resolve(result);
      }
    );
  });
};

module.exports = { uploadToCloudinary };