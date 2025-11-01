// ============================================
// CLASSIC TEMPLATE - Blue-Collar Resume
// ============================================
// Traditional, professional format
// Perfect for: Experienced workers, traditional companies
// Font: Times New Roman | Layout: Single column centered
// ATS Score: 5/5 - Excellent compatibility
// ============================================

#let classic_resume(
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
  
  // Page setup
  set page(
    paper: "us-letter",
    margin: (left: 0.75in, right: 0.75in, top: 0.6in, bottom: 0.6in),
  )
  
  set text(
    font: "Times New Roman",
    size: 11pt,
    lang: "en",
  )
  
  set par(justify: true, leading: 0.7em)
  
  // ============================================
  // HEADER - Traditional centered format
  // ============================================
  align(center)[
    #text(size: 20pt, weight: "bold")[#upper(name)] \
    #v(0.2em)
    #text(size: 12pt)[#trade] \
    #v(0.3em)
    #text(size: 10pt)[
      #location | #phone | #email
    ]
    #if license != "" [
      #v(0.1em)
      #text(size: 10pt)[License: #license]
    ]
  ]
  
  #v(0.4em)
  #align(center)[#line(length: 80%, stroke: 1pt + black)]
  #v(0.5em)
  
  // ============================================
  // PROFESSIONAL SUMMARY
  // ============================================
  if summary != [] [
    #align(center)[
      #text(size: 12pt, weight: "bold")[PROFESSIONAL SUMMARY]
    ]
    #v(0.3em)
    #summary
    #v(0.5em)
  ]
  
  // ============================================
  // QUALIFICATIONS & SKILLS
  // ============================================
  if technical_skills.len() > 0 or safety_certs.len() > 0 [
    #align(center)[
      #text(size: 12pt, weight: "bold")[QUALIFICATIONS & SKILLS]
    ]
    #v(0.3em)
    
    #if technical_skills.len() > 0 [
      #text(weight: "bold")[Technical Expertise] \
      #v(0.1em)
      #for skill in technical_skills [
        #h(1em) • #skill \
      ]
      #v(0.3em)
    ]
    
    #if safety_certs.len() > 0 [
      #text(weight: "bold")[Safety Certifications] \
      #v(0.1em)
      #for cert in safety_certs [
        #h(1em) • #cert \
      ]
      #v(0.3em)
    ]
    #v(0.2em)
  ]
  
  // ============================================
  // PROFESSIONAL EXPERIENCE
  // ============================================
  if experience.len() > 0 [
    #align(center)[
      #text(size: 12pt, weight: "bold")[PROFESSIONAL EXPERIENCE]
    ]
    #v(0.3em)
    
    #for job in experience [
      #block[
        #text(weight: "bold")[#job.title] \
        #text(style: "italic")[#job.company, #job.location] #h(1fr) #text(style: "italic")[#job.dates] \
        #v(0.2em)
        
        #for duty in job.responsibilities [
          #h(1em) • #duty \
        ]
        #v(0.4em)
      ]
    ]
  ]
  
  // ============================================
  // CERTIFICATIONS & LICENSES
  // ============================================
  if certifications.len() > 0 [
    #align(center)[
      #text(size: 12pt, weight: "bold")[CERTIFICATIONS & LICENSES]
    ]
    #v(0.3em)
    
    #for cert in certifications [
      #h(1em) • #text(weight: "bold")[#cert.name], #cert.issuer #if "date" in cert [ - #cert.date] \
    ]
    #v(0.5em)
  ]
  
  // ============================================
  // EDUCATION & TRAINING
  // ============================================
  if education.len() > 0 [
    #align(center)[
      #text(size: 12pt, weight: "bold")[EDUCATION & TRAINING]
    ]
    #v(0.3em)
    
    #for edu in education [
      #text(weight: "bold")[#edu.degree] \
      #text(style: "italic")[#edu.institution, #edu.location] #h(1fr) #text(style: "italic")[#edu.year] \
      #v(0.2em)
    ]
    #v(0.3em)
  ]
  
  // ============================================
  // SAFETY RECORD & ACHIEVEMENTS
  // ============================================
  if safety_record != "" or achievements.len() > 0 [
    #align(center)[
      #text(size: 12pt, weight: "bold")[SAFETY RECORD & ACHIEVEMENTS]
    ]
    #v(0.3em)
    
    #if safety_record != "" [
      #text(weight: "bold")[Safety Record:] #safety_record \
      #v(0.2em)
    ]
    
    #if achievements.len() > 0 [
      #for achievement in achievements [
        #h(1em) • #achievement \
      ]
    ]
  ]
}

// ============================================
// EXAMPLE USAGE - Plumber Resume
// ============================================
// Copy the section below and customize with YOUR information
// ============================================

#show: classic_resume.with(
  name: "Robert Martinez",
  trade: "Licensed Master Plumber",
  phone: "(555) 234-5678",
  email: "r.martinez@email.com",
  location: "Phoenix, AZ",
  license: "AZ Master Plumber #MP-45321",
  
  summary: [
    Dedicated Master Plumber with 12 years of comprehensive experience in residential, commercial, and industrial plumbing systems. Expert in installation, maintenance, troubleshooting, and repair of water supply lines, drainage systems, and gas piping. Proven track record of delivering high-quality work while maintaining strict adherence to plumbing codes and safety standards. Committed to providing exceptional customer service and efficient problem-solving solutions.
  ],
  
  technical_skills: (
    "Complete plumbing system installation and repair",
    "Water heater installation (gas, electric, tankless)",
    "Drain cleaning and sewer line repair",
    "Gas line installation and testing",
    "Backflow prevention and testing",
    "Pipe threading, soldering, and welding",
    "Blueprint reading and job estimation",
    "PEX, copper, and PVC pipe systems",
  ),
  
  safety_certs: (
    "OSHA 30-Hour Construction Safety Certification",
    "Backflow Prevention Tester Certification",
    "Gas Line Installation Certification",
    "First Aid and CPR Certified",
    "Confined Space Entry Training",
    "Trenching and Excavation Safety",
  ),
  
  experience: (
    (
      title: "Master Plumber / Shop Foreman",
      company: "Desert Valley Plumbing Services",
      location: "Phoenix, AZ",
      dates: "January 2018 - Present",
      responsibilities: (
        "Oversee daily operations of 8-person plumbing crew, managing scheduling, quality control, and customer relations for residential and commercial projects",
        "Successfully completed 500+ plumbing installations and service calls with 97% customer satisfaction rate",
        "Install and repair water supply systems, drainage systems, and gas lines in compliance with IPC and UPC codes",
        "Perform backflow prevention testing for 100+ commercial properties annually, maintaining 100% compliance",
        "Reduced average service call time by 25% through implementation of improved diagnostic procedures",
        "Train and mentor apprentice plumbers, with 5 successfully obtaining journeyman licenses under supervision",
      ),
    ),
    (
      title: "Journeyman Plumber",
      company: "Southwest Plumbing & Heating",
      location: "Phoenix, AZ",
      dates: "June 2014 - December 2017",
      responsibilities: (
        "Installed and maintained plumbing systems for residential properties, including water heaters, fixtures, and drainage systems",
        "Diagnosed and repaired plumbing issues, achieving 95% first-call resolution rate",
        "Completed 400+ service calls annually with average customer rating of 4.8 out of 5 stars",
        "Installed over 200 water heaters (tankless, gas, and electric) with zero callback rate",
        "Assisted in commercial plumbing projects including restaurants, office buildings, and retail spaces",
      ),
    ),
    (
      title: "Plumber's Apprentice",
      company: "Reliable Plumbing Co.",
      location: "Phoenix, AZ",
      dates: "March 2012 - May 2014",
      responsibilities: (
        "Assisted journeyman and master plumbers with installations, repairs, and maintenance tasks",
        "Gained hands-on experience in residential and commercial plumbing systems",
        "Learned proper use of plumbing tools, equipment, and safety procedures",
        "Completed 4-year apprenticeship program with 8,000+ documented training hours",
      ),
    ),
  ),
  
  certifications: (
    (name: "Master Plumber License", issuer: "Arizona Registrar of Contractors", date: "2018"),
    (name: "Journeyman Plumber License", issuer: "Arizona Registrar of Contractors", date: "2014"),
    (name: "Backflow Prevention Tester", issuer: "American Backflow Prevention Association", date: "2019"),
    (name: "Medical Gas Installer", issuer: "ASSE International", date: "2020"),
    (name: "OSHA 30-Hour Construction", issuer: "Occupational Safety and Health Administration", date: "2017"),
  ),
  
  education: (
    (
      degree: "Plumbing Technology Certificate",
      institution: "Phoenix Technical Institute",
      location: "Phoenix, AZ",
      year: "2012",
    ),
    (
      degree: "Four-Year Plumbing Apprenticeship Program",
      institution: "Arizona Plumbers Union Local 469",
      location: "Phoenix, AZ",
      year: "2014",
    ),
  ),
  
  safety_record: "12 years with zero lost-time accidents and zero safety violations",
  
  achievements: (
    "Master Plumber of the Year - Phoenix Metro Plumbing Association (2021)",
    "Maintained 97% customer satisfaction rating over 6 years",
    "Completed 750+ jobs with zero major callbacks or warranty issues",
    "Successfully trained and mentored 5 apprentices to journeyman status",
    "Achieved $1.2M in annual revenue for company through exceptional service and repeat business",
  ),
)

// ============================================
// CUSTOMIZATION INSTRUCTIONS
// ============================================
// 1. Replace the example data above with YOUR information
// 2. Keep the same structure and format
// 3. Use action verbs: Led, Managed, Completed, Achieved, etc.
// 4. Quantify achievements with numbers whenever possible
// 5. List most recent job first (reverse chronological order)
// 6. Save this file with a .typ extension
// 7. Compile using: typst compile yourfile.typ output.pdf
//    Or use the Typst web app at https://typst.app
// ============================================