// ============================================
// MODERN TEMPLATE - Blue-Collar Resume
// ============================================
// Clean, contemporary design with subtle colors
// Perfect for: All trades, younger workers

#let modern_resume(
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
  
  // Color scheme
  accent_color: rgb("#2c5aa0"),
) = {
  
  // Page setup
  set page(
    paper: "us-letter",
    margin: (left: 0.6in, right: 0.6in, top: 0.5in, bottom: 0.5in),
  )
  
  set text(
    font: "Arial",
    size: 10pt,
    lang: "en",
  )
  
  set par(justify: true, leading: 0.65em)
  
  // ============================================
  // HEADER - Name and Contact
  // ============================================
  align(center)[
    #block[
      #text(size: 24pt, weight: "bold", fill: accent_color)[#name] \
      #v(0.1em)
      #text(size: 13pt, weight: "semibold", fill: rgb("#333333"))[#trade] \
      #v(0.3em)
      #text(size: 9pt)[
        #phone | #email | #location #if license != "" [ | License: #license]
      ]
    ]
  ]
  
  #line(length: 100%, stroke: 1pt + accent_color)
  #v(0.3em)
  
  // ============================================
  // PROFESSIONAL SUMMARY
  // ============================================
  if summary != [] [
    #text(size: 12pt, weight: "bold", fill: accent_color)[PROFESSIONAL SUMMARY]
    #v(0.2em)
    #line(length: 100%, stroke: 0.5pt + gray)
    #v(0.3em)
    #summary
    #v(0.4em)
  ]
  
  // ============================================
  // CORE COMPETENCIES (Skills)
  // ============================================
  if technical_skills.len() > 0 or safety_certs.len() > 0 [
    #text(size: 12pt, weight: "bold", fill: accent_color)[CORE COMPETENCIES]
    #v(0.2em)
    #line(length: 100%, stroke: 0.5pt + gray)
    #v(0.3em)
    
    #grid(
      columns: 2,
      column-gutter: 1em,
      row-gutter: 0.5em,
      
      // Technical Skills Column
      [
        #text(weight: "semibold")[Technical Skills:] \
        #for skill in technical_skills [
          • #skill \
        ]
      ],
      
      // Safety Certifications Column
      [
        #text(weight: "semibold")[Safety Certifications:] \
        #for cert in safety_certs [
          • #cert \
        ]
      ]
    )
    #v(0.4em)
  ]
  
  // ============================================
  // WORK EXPERIENCE
  // ============================================
  if experience.len() > 0 [
    #text(size: 12pt, weight: "bold", fill: accent_color)[WORK EXPERIENCE]
    #v(0.2em)
    #line(length: 100%, stroke: 0.5pt + gray)
    #v(0.3em)
    
    #for job in experience [
      #block[
        #grid(
          columns: (1fr, auto),
          [#text(weight: "bold", size: 11pt)[#job.title]], 
          [#text(style: "italic")[#job.dates]]
        )
        #text(weight: "semibold")[#job.company], #job.location
        #v(0.2em)
        
        #for duty in job.responsibilities [
          • #duty \
        ]
        #v(0.3em)
      ]
    ]
  ]
  
  // ============================================
  // CERTIFICATIONS & LICENSES
  // ============================================
  if certifications.len() > 0 [
    #text(size: 12pt, weight: "bold", fill: accent_color)[CERTIFICATIONS & LICENSES]
    #v(0.2em)
    #line(length: 100%, stroke: 0.5pt + gray)
    #v(0.3em)
    
    #for cert in certifications [
      • *#cert.name* - #cert.issuer #if "date" in cert [ (#cert.date)] \
    ]
    #v(0.4em)
  ]
  
  // ============================================
  // EDUCATION & TRAINING
  // ============================================
  if education.len() > 0 [
    #text(size: 12pt, weight: "bold", fill: accent_color)[EDUCATION & TRAINING]
    #v(0.2em)
    #line(length: 100%, stroke: 0.5pt + gray)
    #v(0.3em)
    
    #for edu in education [
      #block[
        #grid(
          columns: (1fr, auto),
          [#text(weight: "bold")[#edu.degree]], 
          [#text(style: "italic")[#edu.year]]
        )
        #edu.institution, #edu.location \
        #v(0.2em)
      ]
    ]
  ]
  
  // ============================================
  // SAFETY RECORD & ACHIEVEMENTS
  // ============================================
  if safety_record != "" or achievements.len() > 0 [
    #text(size: 12pt, weight: "bold", fill: accent_color)[SAFETY RECORD & ACHIEVEMENTS]
    #v(0.2em)
    #line(length: 100%, stroke: 0.5pt + gray)
    #v(0.3em)
    
    #if safety_record != "" [
      #text(weight: "semibold", fill: rgb("#006400"))[Safety Record:] #safety_record \
      #v(0.2em)
    ]
    
    #if achievements.len() > 0 [
      #text(weight: "semibold")[Key Achievements:] \
      #for achievement in achievements [
        • #achievement \
      ]
    ]
  ]
}

// ============================================
// EXAMPLE USAGE - Electrician Resume
// ============================================

#show: modern_resume.with(
  name: "Michael Thompson",
  trade: "Licensed Master Electrician",
  phone: "(555) 123-4567",
  email: "m.thompson@email.com",
  location: "Houston, TX",
  license: "TX Master Electrician #ME-87654",
  
  summary: [
    Highly skilled Master Electrician with 8+ years of experience in commercial and residential electrical installations, maintenance, and repairs. Proven expertise in reading blueprints, troubleshooting complex electrical systems, and ensuring code compliance. Strong safety record with zero workplace incidents. Committed to delivering quality workmanship and excellent customer service.
  ],
  
  technical_skills: (
    "Electrical system installation & repair",
    "Blueprint reading & interpretation",
    "NEC code compliance",
    "Conduit bending & installation",
    "Panel upgrades & circuit design",
    "Troubleshooting & diagnostics",
    "LED lighting systems",
    "Motor controls & automation",
  ),
  
  safety_certs: (
    "OSHA 30-Hour Construction",
    "Arc Flash Safety Training",
    "First Aid/CPR Certified",
    "Confined Space Entry",
    "Lockout/Tagout (LOTO)",
    "Aerial Lift Operator",
  ),
  
  experience: (
    (
      title: "Master Electrician",
      company: "Premier Electric Solutions",
      location: "Houston, TX",
      dates: "June 2019 - Present",
      responsibilities: (
        "Lead electrical installations for commercial projects valued up to $500K, consistently completing on time and under budget",
        "Supervise team of 4 apprentice electricians, providing hands-on training and mentorship",
        "Perform electrical inspections and troubleshooting for facilities ranging from 5,000 to 50,000 sq ft",
        "Upgraded over 120 electrical panels to meet current NEC standards, improving safety compliance by 100%",
        "Reduced material waste by 15% through efficient planning and inventory management",
      ),
    ),
    (
      title: "Journeyman Electrician",
      company: "Bright Star Electrical Contractors",
      location: "Houston, TX",
      dates: "March 2016 - May 2019",
      responsibilities: (
        "Installed and maintained electrical systems in residential and light commercial buildings",
        "Completed over 300 service calls with 98% customer satisfaction rating",
        "Diagnosed and repaired electrical faults, reducing downtime for commercial clients by average of 4 hours",
        "Assisted in training 6 apprentices in safe electrical practices and code compliance",
        "Maintained zero safety incidents over 3-year period while working 4,500+ hours",
      ),
    ),
  ),
  
  certifications: (
    (name: "Master Electrician License", issuer: "Texas Department of Licensing", date: "2019"),
    (name: "Journeyman Electrician License", issuer: "Texas Department of Licensing", date: "2016"),
    (name: "NICET Level II - Fire Alarm Systems", issuer: "NICET", date: "2020"),
    (name: "OSHA 30-Hour Construction Safety", issuer: "OSHA", date: "2018"),
  ),
  
  education: (
    (
      degree: "Electrical Technology Diploma",
      institution: "Houston Community College",
      location: "Houston, TX",
      year: "2015",
    ),
    (
      degree: "4-Year Electrical Apprenticeship Program",
      institution: "Independent Electrical Contractors (IEC)",
      location: "Houston, TX",
      year: "2016",
    ),
  ),
  
  safety_record: "8 years, 16,000+ hours with ZERO lost-time incidents",
  
  achievements: (
    "Awarded 'Electrician of the Year' by Premier Electric Solutions (2022)",
    "Completed 250+ residential panel upgrades with 100% pass rate on electrical inspections",
    "Reduced average project completion time by 20% through improved workflow processes",
    "Mentored 10 apprentices, with 8 successfully obtaining journeyman licenses",
  ),
  
  accent_color: rgb("#2c5aa0"),
)