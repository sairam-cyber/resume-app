// services/pdfService.js
const fs = require('fs');
const path = require('path');
const { PDFDocument, StandardFonts, rgb } = require('pdf-lib');
const fontkit = require('@pdf-lib/fontkit');

// --- Helper Functions ---

// Safe getter for Map or plain object
const get = (data, key, fallback = '') => {
  if (!data) return fallback;
  if (data instanceof Map) {
    return data.has(key) ? (data.get(key) ?? fallback) : fallback;
  }
  return data[key] ?? fallback;
};

// Formats comma-separated strings into bullet points
const formatArrayAsBullets = (commaString) => {
  if (!commaString || typeof commaString !== 'string') return [];
  return commaString
    .split(',')
    .map((s) => `• ${s.trim()}`)
    .filter((s) => s.length > 2);
};

// Main function to generate the PDF
async function generateBlueCollarPdf(resumeData, user) {
  const resume = await PDFDocument.create();
  
  // Register fontkit
  resume.registerFontkit(fontkit);
  
  // Embed a standard font
  // We use Helvetica as a safe, universal font.
  const font = await resume.embedFont(StandardFonts.Helvetica);
  const boldFont = await resume.embedFont(StandardFonts.HelveticaBold);
  
  const page = resume.addPage();
  const { width, height } = page.getSize();
  const margin = 50;
  let y = height - margin; // Start from top

  const primaryColor = rgb(0.05, 0.2, 0.4); // Dark Blue
  const secondaryColor = rgb(0.2, 0.2, 0.2); // Dark Gray
  const bodyColor = rgb(0.1, 0.1, 0.1);

  // --- 1. Header (Name & Trade) ---
  const name = get(resumeData, 'name');
  const trade = get(resumeData, 'trade');
  
  page.drawText(name, {
    x: margin,
    y: y,
    size: 28,
    font: boldFont,
    color: primaryColor,
  });
  y -= 32;

  page.drawText(trade, {
    x: margin,
    y: y,
    size: 18,
    font: font,
    color: secondaryColor,
  });
  y -= 25;

  // --- 2. Contact Info ---
  const phone = get(resumeData, 'phone');
  const email = get(resumeData, 'email');
  const location = get(resumeData, 'location');
  const contactText = `${phone}  |  ${email}  |  ${location}`;
  
  page.drawText(contactText, {
    x: margin,
    y: y,
    size: 11,
    font: font,
    color: bodyColor,
  });
  y -= 30;

  // --- 3. Summary ---
  const summary = get(resumeData, 'summary');
  if (summary) {
    page.drawText('Professional Summary', {
      x: margin, y: y, size: 16, font: boldFont, color: primaryColor
    });
    y -= 18;
    page.drawText(summary, {
      x: margin, y: y, size: 10, font: font, color: bodyColor, maxWidth: width - (margin * 2), lineHeight: 14
    });
    y -= (summary.length > 150 ? 60 : 45);
  }

  // --- 4. Skills ---
  const skills = formatArrayAsBullets(get(resumeData, 'technical_skills'));
  if (skills.length > 0) {
    page.drawText('Technical Skills', {
      x: margin, y: y, size: 16, font: boldFont, color: primaryColor
    });
    y -= 20;

    // Draw as two columns
    const midPoint = Math.ceil(skills.length / 2);
    const col1 = skills.slice(0, midPoint);
    const col2 = skills.slice(midPoint);
    const colWidth = (width - (margin * 2)) / 2;

    let y_col1 = y;
    col1.forEach(skill => {
      page.drawText(skill, { x: margin, y: y_col1, size: 10, font: font, color: bodyColor });
      y_col1 -= 14;
    });
    
    let y_col2 = y;
    col2.forEach(skill => {
      page.drawText(skill, { x: margin + colWidth, y: y_col2, size: 10, font: font, color: bodyColor });
      y_col2 -= 14;
    });
    y = Math.min(y_col1, y_col2) - 15; // Move Y to the end of the longest column
  }

  // --- 5. Work Experience ---
  if (get(resumeData, 'exp1_title')) {
    page.drawText('Work Experience', {
      x: margin, y: y, size: 16, font: boldFont, color: primaryColor
    });
    y -= 20;

    for (let i = 1; i <= 2; i++) {
      const title = get(resumeData, `exp${i}_title`);
      if (!title) continue;
      
      const company = get(resumeData, `exp${i}_company`);
      const dates = get(resumeData, `exp${i}_dates`);
      const location = get(resumeData, `exp${i}_location`);
      const responsibilities = formatArrayAsBullets(get(resumeData, `exp${i}_responsibilities`));

      page.drawText(title, { x: margin, y: y, size: 12, font: boldFont, color: bodyColor });
      page.drawText(dates, { x: width - margin - 100, y: y, size: 11, font: font, color: secondaryColor });
      y -= 16;
      
      page.drawText(`${company} | ${location}`, { x: margin, y: y, size: 11, font: font, color: secondaryColor });
      y -= 16;
      
      responsibilities.forEach(line => {
        page.drawText(line, { x: margin + 10, y: y, size: 10, font: font, color: bodyColor });
        y -= 14;
      });
      y -= 10;
    }
  }
  
  // --- 6. Education ---
  if (get(resumeData, 'edu1_degree')) {
    page.drawText('Education & Certifications', {
      x: margin, y: y, size: 16, font: boldFont, color: primaryColor
    });
    y -= 20;
    
    // Education
    for (let i = 1; i <= 2; i++) {
      const degree = get(resumeData, `edu${i}_degree`);
      if (!degree) continue;
      const institution = get(resumeData, `edu${i}_institution`);
      const year = get(resumeData, `edu${i}_year`);

      page.drawText(degree, { x: margin, y: y, size: 12, font: boldFont, color: bodyColor });
      page.drawText(year, { x: width - margin - 50, y: y, size: 11, font: font, color: secondaryColor });
      y -= 16;
      page.drawText(institution, { x: margin, y: y, size: 11, font: font, color: secondaryColor });
      y -= 20;
    }
    
    // Certifications
    for (let i = 1; i <= 2; i++) {
        const certName = get(resumeData, `cert${i}_name`);
        if (!certName) continue;
        const issuer = get(resumeData, `cert${i}_issuer`);
        const date = get(resumeData, `cert${i}_date`);
        
        page.drawText(certName, { x: margin, y: y, size: 12, font: boldFont, color: bodyColor });
        page.drawText(date, { x: width - margin - 50, y: y, size: 11, font: font, color: secondaryColor });
        y -= 16;
        page.drawText(issuer, { x: margin, y: y, size: 11, font: font, color: secondaryColor });
        y -= 20;
    }
  }

  // --- Save PDF to file ---
  const pdfBytes = await resume.save();
  
  // Create a temp file path
  const tempDir = path.join(__dirname, '..', 'temp');
  if (!fs.existsSync(tempDir)) {
    fs.mkdirSync(tempDir, { recursive: true });
  }
  const pdfFilePath = path.join(tempDir, `resume_${user._id}.pdf`);
  
  // Write the file
  fs.writeFileSync(pdfFilePath, pdfBytes);
  
  return pdfFilePath;
}

module.exports = { generateBlueCollarPdf };