// ============================================
// SIMPLE TEMPLATE - Blue-Collar Resume
// ============================================
// Minimalist, clean, highly ATS-friendly
// Perfect for: ATS systems, online applications, any trade
// Font: Arial | Layout: Single column, plain text
// ATS Score: 5/5 - EXCELLENT (Maximum compatibility)
// ============================================

#let simple_resume(
  // Personal Information
  name: "",
  trade: "",
  phone: "",
  email: "",
  location: "",
  license: "",
  
  // Professional Summary
  summary: [],
  
  // Skills
  technical_skills: (),
  safety_certs: (),
  
  // Work Experience
  experience: (),
  
  // Certifications
  certifications: (),
  
  // Education
  education: (),
  
  // Safety Record
  safety_record: "",
  
  // Achievements
  achievements: (),
) = {
  
  // Page setup - Maximum ATS compatibility
  set page(
    paper: "us-letter",
    margin: (left: 0.75in, right: 0.75in, top: 0.75in, bottom: 0.75in),
  )
  
  set text(
    font: "Arial",
    size: 11pt,
    lang: "en",
  )
  
  set par(justify: false, leading: 0.65em)
  
  // ============================================
  // HEADER - Simple and clean
  // ============================================
  
  text(size: 18pt, weight: "bold")[#name] \
  text(size: 12pt)[#trade] \
  #v(0.2em)
  #phone | #email | #location #if license != "" [ | #license] \
  
  #v(0.3em)
  #line(length: 100%, stroke: 1pt + black)
  #v(0.4em)
  
  // ============================================
  // PROFESSIONAL SUMMARY
  // ============================================
  if summary != [] [
    #text(size: 12pt, weight: "bold")[PROFESSIONAL SUMMARY]
    #v(0.2em)
    #summary
    #v(0.5em)
  ]
  
  // ============================================
  // SKILLS
  // ============================================
  if technical_skills.len() > 0 [
    #text(size: 12pt, weight: "bold")[TECHNICAL SKILLS]
    #v(0.2em)
    #for skill in technical_skills [
      • #skill \
    ]
    #v(0.5em)
  ]
  
  // ============================================
  // SAFETY CERTIFICATIONS
  // ============================================
  if safety_certs.len() > 0 [
    #text(size: 12pt, weight: "bold")[SAFETY CERTIFICATIONS]
    #v(0.2em)
    #for cert in safety_certs [
      • #cert \
    ]
    #v(0.5em)
  ]
  
  // ============================================
  // WORK EXPERIENCE
  // ============================================
  if experience.len() > 0 [
    #text(size: 12pt, weight: "bold")[WORK EXPERIENCE]
    #v(0.2em)
    
    #for job in experience [
      #block[
        #text(weight: "bold")[#job.title] \
        #job.company, #job.location \
        #job.dates \
        #v(0.2em)
        
        #for duty in job.responsibilities [
          • #duty \
        ]
        #v(0.4em)
      ]
    ]
  ]
  
  // ============================================
  // CERTIFICATIONS & LICENSES
  // ============================================
  if certifications.len() > 0 [
    #text(size: 12pt, weight: "bold")[CERTIFICATIONS & LICENSES]
    #v(0.2em)
    
    #for cert in certifications [
      • #cert.name, #cert.issuer #if "date" in cert [ - #cert.date] \
    ]
    #v(0.5em)
  ]
  
  // ============================================
  // EDUCATION
  // ============================================
  if education.len() > 0 [
    #text(size: 12pt, weight: "bold")[EDUCATION]
    #v(0.2em)
    
    #for edu in education [
      #text(weight: "bold")[#edu.degree] \
      #edu.institution, #edu.location - #edu.year \
      #v(0.2em)
    ]
    #v(0.3em)
  ]
  
  // ============================================
  // SAFETY RECORD
  // ============================================
  if safety_record != "" [
    #text(size: 12pt, weight: "bold")[SAFETY RECORD]
    #v(0.2em)
    #safety_record
    #v(0.5em)
  ]
  
  // ============================================
  // ACHIEVEMENTS
  // ============================================
  if achievements.len() > 0 [
    #text(size: 12pt, weight: "bold")[ACHIEVEMENTS]
    #v(0.2em)
    
    #for achievement in achievements [
      • #achievement \
    ]
  ]
}

// ============================================
// EXAMPLE USAGE - Commercial Truck Driver Resume
// ============================================
// Copy the section below and customize with YOUR information
// ============================================

#show: simple_resume.with(
  name: "James Wilson",
  trade: "Commercial Truck Driver - CDL Class A",
  phone: "(555) 567-8901",
  email: "james.wilson@email.com",
  location: "Dallas, TX",
  license: "CDL Class A with Hazmat & Tanker",
  
  summary: [
    Safety-focused Commercial Truck Driver with 10 years of experience operating tractor-trailers across 48 states. Clean driving record with over 1 million miles of accident-free driving. Expert in long-haul transportation, hazardous materials handling, and DOT compliance. Proven ability to maintain equipment, meet delivery schedules, and provide excellent customer service. Dedicated to safety, efficiency, and professional representation of every employer.
  ],
  
  technical_skills: (
    "Tractor-trailer operation (53-foot dry van and refrigerated)",
    "Hazardous materials transportation",
    "Electronic logging device (ELD) operation",
    "Pre-trip and post-trip inspections",
    "Load securing and weight distribution",
    "GPS navigation and route planning",
    "Basic mechanical troubleshooting",
    "DOT regulations and Hours of Service compliance",
  ),
  
  safety_certs: (
    "CDL Class A License with Hazmat and Tanker endorsements",
    "Transportation Worker Identification Credential (TWIC)",
    "Defensive Driving Course Certified",
    "Smith System Driver Training",
    "Hazmat Transportation Certification",
    "First Aid and CPR Certified",
  ),
  
  experience: (
    (
      title: "Long-Haul Truck Driver",
      company: "Nationwide Freight Services",
      location: "Dallas, TX",
      dates: "March 2018 - Present",
      responsibilities: (
        "Transport freight across 48 states with 100% on-time delivery record for past 3 years",
        "Maintain clean DOT safety record with zero accidents, violations, or citations",
        "Operate 53-foot tractor-trailer combinations hauling general freight and temperature-controlled goods",
        "Complete thorough pre-trip and post-trip vehicle inspections ensuring safety and compliance",
        "Maintain accurate electronic logs using ELD systems in full compliance with FMCSA regulations",
        "Communicate effectively with dispatch, customers, and shipping/receiving personnel",
        "Average 2,500 miles per week with 98% fuel efficiency rating",
        "Completed over 500,000 accident-free miles with current employer",
      ),
    ),
    (
      title: "Regional Truck Driver",
      company: "Southwest Logistics Inc.",
      location: "Dallas, TX",
      dates: "June 2014 - February 2018",
      responsibilities: (
        "Delivered freight within 500-mile radius covering Texas, Oklahoma, Arkansas, and Louisiana",
        "Operated dry van and flatbed trailers transporting various commercial goods",
        "Achieved 99% on-time delivery rate across 2,000+ deliveries",
        "Maintained DOT-compliant logbooks and vehicle inspection reports",
        "Performed minor repairs and maintenance to reduce downtime",
        "Exceeded company fuel efficiency standards by 12% through proper trip planning",
        "Accumulated over 400,000 safe driving miles",
      ),
    ),
  ),
  
  certifications: (
    (name: "CDL Class A License", issuer: "Texas Department of Public Safety", date: "2014 (Current)"),
    (name: "Hazmat Endorsement", issuer: "TSA", date: "2015 (Renewed 2023)"),
    (name: "Tanker Endorsement", issuer: "Texas DPS", date: "2016"),
    (name: "TWIC Card", issuer: "Transportation Security Administration", date: "2019"),
    (name: "Smith System Driver Trainer", issuer: "Smith System", date: "2020"),
  ),
  
  education: (
    (
      degree: "Commercial Truck Driving Certificate",
      institution: "Dallas Truck Driving School",
      location: "Dallas, TX",
      year: "2014",
    ),
    (
      degree: "High School Diploma",
      institution: "Dallas High School",
      location: "Dallas, TX",
      year: "2012",
    ),
  ),
  
  safety_record: "10 years, 1,000,000+ miles with ZERO at-fault accidents, ZERO moving violations, ZERO DOT violations",
  
  achievements: (
    "Million Mile Safe Driver Award - Nationwide Freight Services (2024)",
    "Driver of the Year Award - Southwest Logistics Inc. (2017)",
    "Perfect DOT inspection record - 15 consecutive inspections with zero violations",
    "100% on-time delivery performance for 36 consecutive months",
    "Fuel efficiency leader - Exceeded company average by 12% for 5 consecutive years",
    "Zero cargo claims - 100% damage-free delivery record",
  ),
)

// ============================================
// CUSTOMIZATION INSTRUCTIONS
// ============================================
// 1. Replace the example data above with YOUR information
// 2. This template is designed for MAXIMUM ATS compatibility
// 3. NO graphics, NO colors, NO fancy formatting = ATS-friendly
// 4. Use simple bullet points (•) for all lists
// 5. Keep formatting consistent throughout
// 6. Use standard section headers (all caps, bold)
// 7. Include keywords from job descriptions in your skills/experience
// 8. Quantify everything: numbers, percentages, dollar amounts
// 9. List most recent job first (reverse chronological)
// 10. This template works for ALL trades:
//     - Truck Drivers, Electricians, Plumbers
//     - Mechanics, Welders, HVAC Technicians
//     - Construction Workers, Operators
//     - ANY blue-collar profession
// 11. Perfect for: Indeed, LinkedIn, ZipRecruiter, Monster
//     Company career portals, online applications
// 12. Save this file with a .typ extension
// 13. Compile using: typst compile yourfile.typ output.pdf
//     Or use the Typst web app at https://typst.app
// 
// WHY THIS TEMPLATE FOR ONLINE APPLICATIONS:
// - ATS (Applicant Tracking Systems) can read every word
// - No formatting issues when parsed by software
// - Keywords are easily detected
// - Clean, professional appearance
// - Prints perfectly in black and white
// - Universal compatibility across all systems
// ============================================