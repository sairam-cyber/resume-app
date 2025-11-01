// services/typstService.js
const fs = require('fs');
const path = require('path');
const { exec } = require('child_process');

// ---------- HELPERS ----------

// Safe getter for Map or plain object
const get = (data, key, fallback = '') => {
  if (!data) return fallback;
  if (data instanceof Map) {
    return data.has(key) ? (data.get(key) ?? fallback) : fallback;
  }
  if (typeof data === 'object' && data !== null && Object.prototype.hasOwnProperty.call(data, key)) {
    return data[key] ?? fallback;
  }
  return fallback;
};

// "a, b, c" -> "\"a\", \"b\", \"c\"" (Typst tuple content)
const formatArray = (commaString) => {
  if (!commaString || typeof commaString !== 'string') return '';
  return commaString
    .split(',')
    .map((s) => `"${s.trim().replace(/"/g, '\\"')}"`)
    .join(', ');
};

// Wrap summary in a Typst block, escaping special characters
const formatSummary = (summary) => {
  if (!summary || typeof summary !== 'string') return '[]';
  const esc = summary.trim().replace(/\\/g, '\\\\').replace(/\[/g, '\\[').replace(/\]/g, '\\]');
  return `[${esc}]`;
};

// Build experience tuple of objects
const formatExperience = (data) => {
  const out = [];
  for (let i = 1; i <= 3; i++) {
    const title = get(data, `exp${i}_title`);
    if (!title) continue;
    const company = get(data, `exp${i}_company`);
    const location = get(data, `exp${i}_location`);
    const dates = get(data, `exp${i}_dates`);
    const responsibilities = formatArray(get(data, `exp${i}_responsibilities`));
    out.push(
      `(\n` +
        ` title: "${String(title).replace(/"/g, '\\"')}",\n` +
        ` company: "${String(company).replace(/"/g, '\\"')}",\n` +
        ` location: "${String(location).replace(/"/g, '\\"')}",\n` +
        ` dates: "${String(dates).replace(/"/g, '\\"')}",\n` +
        ` responsibilities: (${responsibilities}),\n` +
      `)`
    );
  }
  return out.join(',\n');
};

// Build certifications tuple of objects
const formatCerts = (data) => {
  const out = [];
  for (let i = 1; i <= 3; i++) {
    const name = get(data, `cert${i}_name`);
    if (!name) continue;
    const issuer = get(data, `cert${i}_issuer`);
    const date = get(data, `cert${i}_date`);
    const dateField = (date && date.trim() !== '') ? `,\n date: "${date.trim().replace(/"/g, '\\"')}"` : '';
    out.push(
      `(\n` +
        ` name: "${String(name).replace(/"/g, '\\"')}",\n` +
        ` issuer: "${String(issuer).replace(/"/g, '\\"')}"${dateField}\n` +
      `)`
    );
  }
  return out.join(',\n');
};

// Build education tuple of objects
const formatEducation = (data) => {
  const out = [];
  for (let i = 1; i <= 2; i++) {
    const degree = get(data, `edu${i}_degree`);
    if (!degree) continue;
    const institution = get(data, `edu${i}_institution`);
    const location = get(data, `edu${i}_location`);
    const year = get(data, `edu${i}_year`);
    out.push(
      `(\n` +
        ` degree: "${String(degree).replace(/"/g, '\\"')}",\n` +
        ` institution: "${String(institution).replace(/"/g, '\\"')}",\n` +
        ` location: "${String(location).replace(/"/g, '\\"')}",\n` +
        ` year: "${String(year).replace(/"/g, '\\"')}"\n` +
      `)`
    );
  }
  return out.join(',\n');
};

// ---------- FILE IO ----------
const readTemplateFile = (templateFileName) => {
  const templatePath = path.join(__dirname, '..', 'templates', templateFileName);
  console.log(`Attempting to read template from: ${templatePath}`);
  try {
    if (!fs.existsSync(templatePath)) {
      console.error(`File not found at path: ${templatePath}`);
      throw new Error(`Template file "${templateFileName}" not found at expected path.`);
    }
    let content = fs.readFileSync(templatePath, 'utf-8');
    
    // --- THIS IS THE FIX ---
    // Clean BOM, NBSP, and tags
    content = content.replace(/^\uFEFF/, '').replace(/\u00A0/g, ' ');
    // *** THIS IS THE CORRECTED LINE ***
    content = content.replace(/\\s*/g, '');
    // *** END OF CORRECTION ***
    
    content = content.replace(/\r\n/g, '\n').replace(/\r/g, '\n');
    return content;
  } catch (e) {
    console.error(`Error reading template file: ${templatePath}`, e);
    throw new Error(
      `Failed to read template file "${templateFileName}". Ensure the 'templates' folder exists and contains this file. Path: ${templatePath}. Original error: ${e.message}`
    );
  }
};

// ---------- SHOW RULE ----------
const generateShowRule = (templateName, data) => {
  const esc = (s) => String(s ?? '').replace(/\\/g, '\\\\').replace(/"/g, '\\"');

  const name = esc(get(data, 'name'));
  const trade = esc(get(data, 'trade'));
  const phone = esc(get(data, 'phone'));
  const email = esc(get(data, 'email'));
  const location = esc(get(data, 'location'));
  const license = esc(get(data, 'license'));

  const summary = formatSummary(get(data, 'summary'));
  const technical_skills = formatArray(get(data, 'technical_skills'));
  const safety_certs = formatArray(get(data, 'safety_certs'));
  const experience = formatExperience(data);
  const certifications = formatCerts(data);
  const education = formatEducation(data);
  const safety_record = esc(get(data, 'safety_record'));
  const achievements = formatArray(get(data, 'achievements'));
  const linkedin = esc(get(data, 'linkedin')); // professional_resume only

  let showRule =
    `#show: ${templateName}.with(\n` +
    ` name: "${name}",\n` +
    ` trade: "${trade}",\n` +
    ` phone: "${phone}",\n` +
    ` email: "${email}",\n` +
    ` location: "${location}",\n` +
    ` license: "${license}",\n` +
    ` summary: ${summary},\n` +
    ` technical_skills: (${technical_skills}),\n` +
    ` safety_certs: (${safety_certs}),\n` +
    ` experience: (${experience}),\n` +
    ` certifications: (${certifications}),\n` +
    ` education: (${education}),\n` +
    ` safety_record: "${safety_record}",\n` +
    ` achievements: (${achievements}),\n`;

  if (templateName === 'professional_resume') {
    showRule += ` linkedin: "${linkedin}",\n`;
  }

  showRule += ')\n';
  return showRule;
};

// ---------- FUNCTION EXTRACTION ----------

// Balanced-brace extractor for Typst function definitions
const extractFunctionDefinition = (full, funcName) => {
  const head = `#let ${funcName}(`;
  const startHead = full.indexOf(head);
  if (startHead === -1) return null;

  // Find the closing ')' of the parameter list
  let i = startHead + head.length;
  let depthParens = 1; // we are after '(' in head
  for (; i < full.length; i++) {
    const ch = full[i];
    if (ch === '(') depthParens++;
    else if (ch === ')') {
      depthParens--;
      if (depthParens === 0) { i++; break; }
    }
  }
  // Skip whitespace and '='
  while (i < full.length && /\s/.test(full[i])) i++;
  if (full[i] !== '=') return null;
  i++;
  while (i < full.length && /\s/.test(full[i])) i++;
  if (full[i] !== '{') return null;

  // Scan with brace depth
  let startBody = i;
  let depthBraces = 0;
  let inString = false;
  let stringQuote = null;

  for (; i < full.length; i++) {
    const ch = full[i];
    const prev = i > 0 ? full[i - 1] : '';

    if (inString) {
      if (ch === stringQuote && prev !== '\\') {
        inString = false;
        stringQuote = null;
      }
      continue;
    }

    if (ch === '"' || ch === '\'') {
      inString = true;
      stringQuote = ch;
      continue;
    }

    if (ch === '{') {
      depthBraces++;
    } else if (ch === '}') {
      depthBraces--;
      if (depthBraces === 0) {
        // Include from "#let" start to this closing brace
        return full.substring(startHead, i + 1);
      }
    }
  }
  return null; // unbalanced
};

// ---------- MARKUP BUILDER ----------
const createTypstMarkupFromTemplate = (resumeData, templateKey) => {
  const dataMap = (resumeData instanceof Map) ? resumeData : new Map(Object.entries(resumeData || {}));

  let templateFileName;
  let templateFunctionName;

  switch (templateKey) {
    case 'Modern':
      templateFileName = 'modern-template.typ';
      templateFunctionName = 'modern_resume';
      break;
    case 'Classic':
      templateFileName = 'classic-resume.typ';
      templateFunctionName = 'classic_resume';
      break;
    case 'Professional':
      templateFileName = 'professional-resume.typ';
      templateFunctionName = 'professional_resume';
      break;
    case 'Simple':
      templateFileName = 'simple-resume.typ';
      templateFunctionName = 'simple_resume';
      break;
    case 'Bold':
      templateFileName = 'bold-resume.typ';
      templateFunctionName = 'bold_resume';
      break;
    case 'Creative':
      templateFileName = 'creative-resume.typ';
      templateFunctionName = 'creative_resume';
      break;
    default:
      console.error(`Unknown template key provided: ${templateKey}`);
      throw new Error(`Unknown template key: ${templateKey}. Available: Modern, Classic, Professional, Simple, Bold, Creative.`);
  }

  const fullTemplateContent = readTemplateFile(templateFileName);

  // Primary: balanced extractor
  let functionDefinition = extractFunctionDefinition(fullTemplateContent, templateFunctionName);

  // Fallback: strict regex that expects marker after the function (kept for compatibility)
  if (!functionDefinition) {
    const strictRegex = new RegExp(
      `(#let\\s+${templateFunctionName}\\s*\\([\\s\\S]*?\\)\\s*=\\s*\\{[\\s\\S]*?\\n[\\s\\u00A0]*\\})(?=\\n*[\\s\\u00A0]*// ============================================(?:\\n[\\s\\u00A0]*// EXAMPLE USAGE|\\n[\\s\\u00A0]*// CUSTOMIZATION INSTRUCTIONS))`,
      'm'
    );
    const m2 = fullTemplateContent.match(strictRegex);
    if (m2 && m2[1]) {
      functionDefinition = m2[1];
    } else {
      const expectedIndex = fullTemplateContent.indexOf(`#let ${templateFunctionName}(`);
      const start = Math.max(0, expectedIndex - 200);
      const end = Math.min(fullTemplateContent.length, expectedIndex + 500);
      console.error('Context from cleaned file:\n---\n' + fullTemplateContent.substring(start, end) + '\n---');
      throw new Error(`Could not extract the function definition block for "${templateFunctionName}" in ${templateFileName}.`);
    }
  }

  const showRule = generateShowRule(templateFunctionName, dataMap);
  return functionDefinition + '\n\n' + showRule;
};

// ---------- COMPILATION ----------
const compileTypst = (typstMarkup, resumeId) => {
  const tempDir = path.join(__dirname, '..', 'temp');
  if (!fs.existsSync(tempDir)) {
    try {
      fs.mkdirSync(tempDir, { recursive: true });
      console.log(`Created temp directory: ${tempDir}`);
    } catch (err) {
      console.error(`Error creating temp directory ${tempDir}:`, err);
      return Promise.reject(new Error('Failed to create temporary directory for compilation.'));
    }
  }

  const typstFilePath = path.join(tempDir, `${resumeId}.typ`);
  const pdfFilePath = path.join(tempDir, `${resumeId}.pdf`);

  if (typeof typstMarkup !== 'string') {
    console.error('Invalid typstMarkup type:', typeof typstMarkup);
    return Promise.reject(new Error('Internal server error: Invalid data provided for PDF generation.'));
  }

  try {
    fs.writeFileSync(typstFilePath, typstMarkup, 'utf-8');
    console.log(`Typst file written successfully to: ${typstFilePath}`);
  } catch (writeErr) {
    console.error(`Error writing Typst file ${typstFilePath}:`, writeErr);
    return Promise.reject(new Error('Failed to write temporary Typst file.'));
  }

  return new Promise((resolve, reject) => {
    // *** THIS IS THE FIX for using your global install ***
    const typstBinary = 'typst';
    // *** AND THIS IS THE FIX for the command string ***
    const command = `${typstBinary} compile "${typstFilePath}" "${pdfFilePath}"`;
    
    console.log(`Executing Typst command: ${command}`);

    exec(command, (error, stdout, stderr) => {
      if (fs.existsSync(typstFilePath)) {
        try { fs.unlinkSync(typstFilePath); console.log(`Deleted temp Typst file: ${typstFilePath}`); }
        catch (unlinkErr) { console.error(`Error deleting temp Typst file ${typstFilePath}:`, unlinkErr); }
      }

      if (error) {
        console.error(`Typst execution failed. Exit Code: ${error.code}`);
        console.error(`Typst Stderr:\n${stderr}`);
        console.error(`Typst Stdout:\n${stdout}`);
        if (fs.existsSync(pdfFilePath)) {
          try { fs.unlinkSync(pdfFilePath); console.log(`Deleted potentially corrupted temp PDF file: ${pdfFilePath}`); }
          catch (unlinkPdfErr) { console.error(`Error deleting temp PDF file ${pdfFilePath}:`, unlinkPdfErr); }
        }
        const snippet = typstMarkup.substring(0, 1200);
        return reject(new Error(`Failed to compile resume PDF. Typst compiler error: ${stderr || stdout || error.message || 'Unknown Typst error'}\nProblematic Content:\n${snippet}`));
      }

      if (!fs.existsSync(pdfFilePath)) {
        console.error(`Typst error: PDF file not created at ${pdfFilePath} despite successful execution (Exit Code 0).`);
        console.error(`Typst Stderr:\n${stderr}`);
        console.error(`Typst Stdout:\n${stdout}`);
        return reject(new Error(`Typst command completed but failed to create PDF file. Output: ${stdout} ${stderr}`));
      }

      console.log(`PDF successfully generated: ${pdfFilePath}`);
      resolve(pdfFilePath);
    });
  });
};

// ---------- EXPORTS ----------
module.exports = {
  createTypstMarkupFromTemplate,
  compileTypst,
};