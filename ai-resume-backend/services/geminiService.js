const { GoogleGenerativeAI } = require("@google/generative-ai");

// Initialize the Gemini model
const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);
const model = genAI.getGenerativeModel({ model: "gemini-2.5-flash"});

/**
 * Generates a response from the Gemini API based on a given prompt.
 * @param {string} prompt - The prompt to send to the Gemini API.
 * @returns {Promise<string>} The generated text response.
 */
async function generateText(prompt) {
  try {
    const result = await model.generateContent(prompt);
    const response = await result.response;
    return response.text();
  } catch (error) {
    console.error("Error generating text with Gemini:", error);
    throw new Error("Failed to get response from AI model.");
  }
}

module.exports = { generateText };