// translations/resumeQuestions.js

// --- English ---
const questions_en = [
  { key: 'name', question: 'What is your full name?' },
  { key: 'trade', question: 'What is your trade or job title? (e.g., "Plumber", "Driver")' },
  { key: 'phone', question: 'What is your phone number?' },
  { key: 'email', question: 'What is your email address?' },
  { key: 'location', question: 'What is your current location? (e.g., "Rourkela, Odisha")' },
  { key: 'summary', question: 'Please provide a brief professional summary.' },
  { key: 'license', question: 'What is your driving license number or trade certification?' },
  { key: 'technical_skills', question: 'List your key technical skills, separated by commas.' },
  { key: 'safety_certs', question: 'List any safety certifications you have (e.g., "First Aid"), separated by commas.' },
  { key: 'exp1_title', question: 'What was your most recent job title?' },
  { key: 'exp1_company', question: 'What was the company name?' },
  { key: 'exp1_location', question: 'Where was this job located?' },
  { key: 'exp1_dates', question: 'What were the start and end dates? (e.g., "Jan 2020 - Present")' },
  { key: 'exp1_responsibilities', question: 'List your main responsibilities, separated by commas.' },
  { key: 'exp2_title', question: 'What was your previous job title? (Type "skip" if none)' },
  { key: 'exp2_company', question: 'What was the company name?' },
  { key: 'exp2_location', question: 'Where was this job located?' },
  { key: 'exp2_dates', question: 'What were the start and end dates?' },
  { key: 'exp2_responsibilities', question: 'List your main responsibilities, separated by commas.' },
  { key: 'cert1_name', question: 'What is the name of another certification or training? (Type "skip" to skip)' },
  { key: 'cert1_issuer', question: 'Who issued this certification?' },
  { key: 'cert1_date', question: 'When did you receive it?' },
  { key: 'cert2_name', question: 'Any other certification? (Type "skip" to skip)' },
  { key: 'cert2_issuer', question: 'Who issued this certification?' },
  { key: 'cert2_date', question: 'When did you receive it?' },
  { key: 'edu1_degree', question: 'What is your highest qualification? (e.g., "10th Pass", "ITI Fitter")' },
  { key: 'edu1_institution', question: 'What is the name of your school or institution?' },
  { key: 'edu1_location', question: 'Where was it located?' },
  { key: 'edu1_year', question: 'What year did you complete it?' },
  { key: 'edu2_degree', question: 'Any other qualification? (Type "skip" to skip)' },
  { key: 'edu2_institution', question: 'What is the name of your school or institution?' },
  { key: 'edu2_location', question: 'Where was it located?' },
  { key: 'edu2_year', question: 'What year did you complete it?' },
  { key: 'safety_record', question: 'Describe your safety record (e.g., "Accident-free for 5 years")' },
  { key: 'achievements', question: 'List any awards or achievements, separated by commas.' },
];

// --- Hindi ---
const questions_hi = [
  { key: 'name', question: 'आपका पूरा नाम क्या है?' },
  { key: 'trade', question: 'आपका पेशा या नौकरी का शीर्षक क्या है? (जैसे, "प्लंबर", "ड्राइवर")' },
  { key: 'phone', question: 'आपका फ़ोन नंबर क्या है?' },
  { key: 'email', question: 'आपका ईमेल पता क्या है?' },
  { key: 'location', question: 'आपका वर्तमान स्थान क्या है? (जैसे, "राउरकेला, ओडिशा")' },
  { key: 'summary', question: 'कृपया एक संक्षिप्त पेशेवर सारांश प्रदान करें।' },
  { key: 'license', question: 'आपका ड्राइविंग लाइसेंस नंबर या ट्रेड सर्टिफिकेशन क्या है?' },
  { key: 'technical_skills', question: 'अपने प्रमुख तकनीकी कौशल सूचीबद्ध करें, अल्पविराम से अलग करके।' },
  { key: 'safety_certs', question: 'आपके पास कोई सुरक्षा प्रमाणपत्र सूचीबद्ध करें (जैसे, "प्राथमिक उपचार"), अल्पविराम से अलग करके।' },
  { key: 'exp1_title', question: 'आपकी सबसे हाल की नौकरी का शीर्षक क्या था?' },
  { key: 'exp1_company', question: 'कंपनी का नाम क्या था?' },
  { key: 'exp1_location', question: 'यह नौकरी कहाँ स्थित थी?' },
  { key: 'exp1_dates', question: 'प्रारंभ और समाप्ति तिथियां क्या थीं? (जैसे, "जनवरी 2020 - वर्तमान")' },
  { key: 'exp1_responsibilities', question: 'अपनी मुख्य जिम्मेदारियों को सूचीबद्ध करें, अल्पविराम से अलग करके।' },
  { key: 'exp2_title', question: 'आपका पिछला नौकरी शीर्षक क्या था? (कोई नहीं होने पर "skip" टाइप करें)' },
  { key: 'exp2_company', question: 'कंपनी का नाम क्या था?' },
  { key: 'exp2_location', question: 'यह नौकरी कहाँ स्थित थी?' },
  { key: 'exp2_dates', question: 'प्रारंभ और समाप्ति तिथियां क्या थीं?' },
  { key: 'exp2_responsibilities', question: 'अपनी मुख्य जिम्मेदारियों को सूचीबद्ध करें, अल्पविराम से अलग करके।' },
  { key: 'cert1_name', question: 'किसी अन्य प्रमाणीकरण या प्रशिक्षण का नाम क्या है? (छोड़ने के लिए "skip" टाइप करें)' },
  { key: 'cert1_issuer', question: 'यह प्रमाणीकरण किसने जारी किया?' },
  { key: 'cert1_date', question: 'आपने इसे कब प्राप्त किया?' },
  { key: 'cert2_name', question: 'कोई अन्य प्रमाणीकरण? (छोड़ने के लिए "skip" टाइप करें)' },
  { key: 'cert2_issuer', question: 'यह प्रमाणीकरण किसने जारी किया?' },
  { key: 'cert2_date', question: 'आपने इसे कब प्राप्त किया?' },
  { key: 'edu1_degree', question: 'आपकी उच्चतम योग्यता क्या है? (जैसे, "10वीं पास", "आईटीआई फिटर")' },
  { key: 'edu1_institution', question: 'आपके स्कूल या संस्थान का नाम क्या है?' },
  { key: 'edu1_location', question: 'यह कहाँ स्थित था?' },
  { key: 'edu1_year', question: 'आपने इसे किस वर्ष पूरा किया?' },
  { key: 'edu2_degree', question: 'कोई अन्य योग्यता? (छोड़ने के लिए "skip" टाइप करें)' },
  { key: 'edu2_institution', question: 'आपके स्कूल या संस्थान का नाम क्या है?' },
  { key: 'edu2_location', question: 'यह कहाँ स्थित था?' },
  { key: 'edu2_year', question: 'आपने इसे किस वर्ष पूरा किया?' },
  { key: 'safety_record', question: 'अपने सुरक्षा रिकॉर्ड का वर्णन करें (जैसे, "5 वर्षों से दुर्घटना-मुक्त")' },
  { key: 'achievements', question: 'कोई पुरस्कार या उपलब्धियां सूचीबद्ध करें, अल्पविराम से अलग करके।' },
];

// --- Odia ---
const questions_or = [
  { key: 'name', question: 'ଆପଣଙ୍କର ପୂରା ନାମ କ’ଣ?' },
  { key: 'trade', question: 'ଆପଣଙ୍କର ବାଣିଜ୍ୟ ବା ଚାକିରି ଶୀର୍ଷକ କ’ଣ? (ଯେପରିକି, "ପ୍ଲମ୍ବର", "ଡ୍ରାଇଭର")' },
  { key: 'phone', question: 'ଆପଣଙ୍କର ଫୋନ୍ ନମ୍ବର କ’ଣ?' },
  { key: 'email', question: 'ଆପଣଙ୍କର ଇମେଲ୍ ଠିକଣା କ’ଣ?' },
  { key: 'location', question: 'ଆପଣଙ୍କର ବର୍ତ୍ତମାନର ଅବସ୍ଥାନ କ’ଣ? (ଯେପରିକି, "ରାଉରକେଲା, ଓଡ଼ିଶା")' },
  { key: 'summary', question: 'ଦୟାକରି ଏକ ସଂକ୍ଷିପ୍ତ ବୃତ୍ତିଗତ ସାରାଂଶ ପ୍ରଦାନ କରନ୍ତୁ।' },
  { key: 'license', question: 'ଆପଣଙ୍କର ଡ୍ରାଇଭିଂ ଲାଇସେନ୍ସ ନମ୍ବର କିମ୍ବା ଟ୍ରେଡ୍ ସାର୍ଟିଫିକେସନ୍ କ’ଣ?' },
  { key: 'technical_skills', question: 'ଆପଣଙ୍କର ମୁଖ୍ୟ ବୈଷୟିକ କୌଶଳଗୁଡ଼ିକୁ ତାଲିକାଭୁକ୍ତ କରନ୍ତୁ, କମା ଦ୍ୱାରା ପୃଥକ କରନ୍ତୁ।' },
  { key: 'safety_certs', question: 'ଆପଣଙ୍କର ଥିବା ଯେକୌଣସି ସୁରକ୍ଷା ପ୍ରମାଣପତ୍ର ତାଲିକାଭୁକ୍ତ କରନ୍ତୁ (ଯେପରିକି, "ପ୍ରାଥମିକ ଚିକିତ୍ସା"), କମା ଦ୍ୱାରା ପୃଥକ କରନ୍ତୁ।' },
  { key: 'exp1_title', question: 'ଆପଣଙ୍କର ସର୍ବଶେଷ ଚାକିରି ଶୀର୍ଷକ କ’ଣ ଥିଲା?' },
  { key: 'exp1_company', question: 'କମ୍ପାନୀର ନାମ କ’ଣ ଥିଲା?' },
  { key: 'exp1_location', question: 'ଏହି ଚାକିରି କେଉଁଠାରେ ଥିଲା?' },
  { key: 'exp1_dates', question: 'ଆରମ୍ଭ ଏବଂ ଶେଷ ତାରିଖ କ’ଣ ଥିଲା? (ଯେପରିକି, "ଜାନୁଆରୀ 2020 - ବର୍ତ୍ତମାନ")' },
  { key: 'exp1_responsibilities', question: 'ଆପଣଙ୍କର ମୁଖ୍ୟ ଦାୟିତ୍ୱଗୁଡ଼ିକୁ ତାଲିକାଭୁକ୍ତ କରନ୍ତୁ, କମା ଦ୍ୱାରା ପୃଥକ କରନ୍ତୁ।' },
  { key: 'exp2_title', question: 'ଆପଣଙ୍କର ପୂର୍ବ ଚାକିରି ଶୀର୍ଷକ କ’ଣ ଥିଲା? (ଯଦି କିଛି ନାହିଁ ତେବେ "skip" ଟାଇପ୍ କରନ୍ତୁ)' },
  { key: 'exp2_company', question: 'କମ୍ପାନୀର ନାମ କ’ଣ ଥିଲା?' },
  { key: 'exp2_location', question: 'ଏହି ଚାକିରି କେଉଁଠାରେ ଥିଲା?' },
  { key: 'exp2_dates', question: 'ଆରମ୍ଭ ଏବଂ ଶେଷ ତାରିଖ କ’ଣ ଥିଲା?' },
  { key: 'exp2_responsibilities', question: 'ଆପଣଙ୍କର ମୁଖ୍ୟ ଦାୟିତ୍ୱଗୁଡ଼ିକୁ ତାଲିକାଭୁକ୍ତ କରନ୍ତୁ, କମା ଦ୍ୱାରା ପୃଥକ କରନ୍ତୁ।' },
  { key: 'cert1_name', question: 'ଅନ୍ୟ ଏକ ପ୍ରମାଣପତ୍ର କିମ୍ବା ତାଲିମର ନାମ କ’ଣ? (ଛାଡିବାକୁ "skip" ଟାଇପ୍ କରନ୍ତୁ)' },
  { key: 'cert1_issuer', question: 'ଏହି ପ୍ରମାଣପତ୍ର କିଏ ଜାରି କଲା?' },
  { key: 'cert1_date', question: 'ଆପଣ ଏହାକୁ କେବେ ଗ୍ରହଣ କଲେ?' },
  { key: 'cert2_name', question: 'ଅନ୍ୟ କୌଣସି ପ୍ରମାଣପତ୍ର? (ଛାଡିବାକୁ "skip" ଟାଇପ୍ କରନ୍ତୁ)' },
  { key: 'cert2_issuer', question: 'ଏହି ପ୍ରମାଣପତ୍ର କିଏ ଜାରି କଲା?' },
  { key: 'cert2_date', question: 'ଆପଣ ଏହାକୁ କେବେ ଗ୍ରହଣ କଲେ?' },
  { key: 'edu1_degree', question: 'ଆପଣଙ୍କର ସର୍ବୋଚ୍ଚ ଯୋଗ୍ୟତା କ’ଣ? (ଯେପରିକି, "ଦଶମ ପାସ୍", "ଆଇଟିଆଇ ଫିଟର୍")' },
  { key: 'edu1_institution', question: 'ଆପଣଙ୍କ ସ୍କୁଲ୍ କିମ୍ବା ଅନୁଷ୍ଠାନର ନାମ କ’ଣ?' },
  { key: 'edu1_location', question: 'ଏହା କେଉଁଠାରେ ଅବସ୍ଥିତ ଥିଲା?' },
  { key: 'edu1_year', question: 'ଆପଣ ଏହାକୁ କେଉଁ ବର୍ଷ ସମାପ୍ତ କଲେ?' },
  { key: 'edu2_degree', question: 'ଅନ୍ୟ କୌଣସି ଯୋଗ୍ୟତା? (ଛାଡିବାକୁ "skip" ଟାଇପ୍ କରନ୍ତୁ)' },
  { key: 'edu2_institution', question: 'ଆପଣଙ୍କ ସ୍କୁଲ୍ କିମ୍ବା ଅନୁଷ୍ଠାନର ନାମ କ’ଣ?' },
  { key: 'edu2_location', question: 'ଏହା କେଉଁଠାରେ ଅବସ୍ଥିତ ଥିଲା?' },
  { key: 'edu2_year', question: 'ଆପଣ ଏହାକୁ କେଉଁ ବର୍ଷ ସମାପ୍ତ କଲେ?' },
  { key: 'safety_record', question: 'ଆପଣଙ୍କର ସୁରକ୍ଷା ରେକର୍ଡ ବର୍ଣ୍ଣନା କରନ୍ତୁ (ଯେପରିକି, "5 ବର୍ଷ ଧରି ଦୁର୍ଘଟଣାମୁକ୍ତ")' },
  { key: 'achievements', question: 'କୌଣସି ପୁରସ୍କାର କିମ୍ବା ସଫଳତା ତାଲିକାଭୁକ୍ତ କରନ୍ତୁ, କମା ଦ୍ୱାରା ପୃଥକ କରନ୍ତୁ।' },
];

// --- Helper Functions ---

const getQuestionsByLanguage = (language = 'en') => {
  switch (language) {
    case 'hi':
      return questions_hi;
    case 'or':
      return questions_or;
    case 'en':
    default:
      return questions_en;
  }
};

const getCompletionMessage = (language = 'en') => {
  switch (language) {
    case 'hi':
      return 'बढ़िया! आपका बायोडाटा पूरा हो गया है। अब आप पीडीएफ उत्पन्न कर सकते हैं।';
    case 'or':
      return 'ଉତ୍ତମ! ଆପଣଙ୍କର ରିଜ୍ୟୁମ୍ ସମ୍ପୂର୍ଣ୍ଣ ହୋଇଛି | ଆପଣ ବର୍ତ୍ତମାନ PDF ସୃଷ୍ଟି କରିପାରିବେ |';
    case 'en':
    default:
      return 'Great! Your resume is complete. You can now generate the PDF.';
  }
};

const getLinkedInQuestion = (language = 'en') => {
    switch (language) {
    case 'hi':
      return { key: 'linkedin', question: 'आपकी लिंक्डइन प्रोफ़ाइल यूआरएल क्या है? (वैकल्पिक, "स्किप" टाइप करें)' };
    case 'or':
      return { key: 'linkedin', question: 'ଆପଣଙ୍କର ଲିଙ୍କଡଇନ୍ ପ୍ରୋଫାଇଲ୍ URL କ’ଣ? (ବୈକଳ୍ପିକ, "skip" ଟାଇପ୍ କରନ୍ତୁ)' };
    case 'en':
    default:
      return { key: 'linkedin', question: 'What is your LinkedIn profile URL? (Optional, type "skip")' };
  }
}

module.exports = {
  getQuestionsByLanguage,
  getCompletionMessage,
  getLinkedInQuestion,
};