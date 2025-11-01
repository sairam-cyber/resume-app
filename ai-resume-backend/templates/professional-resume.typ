// ============================================
// PROFESSIONAL TEMPLATE - Blue-Collar Resume
// ============================================
// Corporate-style format with business card header
// Perfect for: Senior positions, supervisory roles, large companies
// Font: Calibri | Layout: Single column with accent boxes
// ATS Score: 4/5 - Very Good
// ============================================

#let professional_resume(
  // Personal Information
  name: "",
  trade: "",
  phone: "",
  email: "",
  location: "",
  license: "",
  linkedin: "",
  
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
  
  // Color scheme (optional - can be customized)
  primary_color: rgb("#1a1a1a"),
  accent_color: rgb("#4a4a4a"),
) = {
  
  // Page setup
  set page(
    paper: "us-letter",
    margin: (left: 0.65in, right: 0.65in, top: 0.5in, bottom: 0.5in),
  )
  
  set text(
    font: "Calibri",
    size: 10.5pt,
    lang: "en",
  )
  
  set par(justify: true, leading: 0.65em)
  
  // ============================================
  // HEADER - Professional business card style
  // ============================================
  
  block(
    width: 100%,
    fill: primary_color,
    inset: 12pt,
    radius: 3pt,
  )[
    #text(size: 22pt, weight: "bold", fill: white)[#name] \
    #v(0.1em)
    #text(size: 12pt, weight: "semibold", fill: rgb("#e0e0e0"))[#trade]
  ]
  
  #v(0.3em)
  
  // Contact bar
  block(
    width: 100%,
    fill: rgb("#f5f5f5"),
    inset: 8pt,
  )[
    #text(size: 9pt)[
      #phone #h(1em) • #h(1em) #email #h(1em) • #h(1em) #location 
      #if license != "" [ #h(1em) • #h(1em) #license]
      #if linkedin != "" [ #h(1em) • #h(1em) #linkedin]
    ]
  ]
  
  #v(0.5em)
  
  // ============================================
  // PROFESSIONAL SUMMARY
  // ============================================
  if summary != [] [
    #block[
      #text(size: 11pt, weight: "bold", fill: primary_color)[■ PROFESSIONAL SUMMARY]
      #v(0.3em)
      #summary
    ]
    #v(0.5em)
  ]
  
  // ============================================
  // CORE COMPETENCIES
  // ============================================
  if technical_skills.len() > 0 or safety_certs.len() > 0 [
    #text(size: 11pt, weight: "bold", fill: primary_color)[■ CORE COMPETENCIES]
    #v(0.3em)
    
    #block(
      width: 100%,
      fill: rgb("#fafafa"),
      inset: 10pt,
      radius: 2pt,
    )[
      #grid(
        columns: 2,
        column-gutter: 2em,
        row-gutter: 0.4em,
        
        // Technical Skills
        [
          #text(weight: "semibold", size: 10pt)[Technical Expertise] \
          #v(0.1em)
          #for skill in technical_skills [
            • #skill \
          ]
        ],
        
        // Safety Certifications
        [
          #text(weight: "semibold", size: 10pt)[Safety & Compliance] \
          #v(0.1em)
          #for cert in safety_certs [
            • #cert \
          ]
        ]
      )
    ]
    #v(0.5em)
  ]
  
  // ============================================
  // PROFESSIONAL EXPERIENCE
  // ============================================
  if experience.len() > 0 [
    #text(size: 11pt, weight: "bold", fill: primary_color)[■ PROFESSIONAL EXPERIENCE]
    #v(0.3em)
    
    #for job in experience [
      #block[
        #grid(
          columns: (1fr, auto),
          [
            #text(weight: "bold", size: 11pt)[#job.title] \
            #text(weight: "semibold", size: 10pt)[#job.company] | #text(size: 9.5pt)[#job.location]
          ],
          [
            #text(style: "italic", size: 9.5pt, fill: accent_color)[#job.dates]
          ]
        )
        #v(0.25em)
        
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
    #text(size: 11pt, weight: "bold", fill: primary_color)[■ CERTIFICATIONS & LICENSES]
    #v(0.3em)
    
    #grid(
      columns: 2,
      column-gutter: 1.5em,
      row-gutter: 0.3em,
      
      ..certifications.map(cert => [
        • #text(weight: "semibold")[#cert.name] \
        #h(0.5em) #text(size: 9pt, style: "italic")[#cert.issuer #if "date" in cert [ | #cert.date]]
      ])
    )
    #v(0.5em)
  ]
  
  // ============================================
  // EDUCATION & TRAINING
  // ============================================
  if education.len() > 0 [
    #text(size: 11pt, weight: "bold", fill: primary_color)[■ EDUCATION & TRAINING]
    #v(0.3em)
    
    #for edu in education [
      #grid(
        columns: (1fr, auto),
        [
          #text(weight: "semibold")[#edu.degree] \
          #text(size: 9.5pt)[#edu.institution, #edu.location]
        ],
        [#text(style: "italic", size: 9.5pt)[#edu.year]]
      )
      #v(0.2em)
    ]
    #v(0.3em)
  ]
  
  // ============================================
  // SAFETY RECORD & KEY ACHIEVEMENTS
  // ============================================
  if safety_record != "" or achievements.len() > 0 [
    #text(size: 11pt, weight: "bold", fill: primary_color)[■ SAFETY RECORD & KEY ACHIEVEMENTS]
    #v(0.3em)
    
    #if safety_record != "" [
      #block(
        width: 100%,
        fill: rgb("#e8f5e9"),
        inset: 8pt,
        radius: 2pt,
      )[
        #text(weight: "semibold", fill: rgb("#2e7d32"))[🛡 Safety Record:] #safety_record
      ]
      #v(0.3em)
    ]
    
    #if achievements.len() > 0 [
      #for achievement in achievements [
        • #achievement \
      ]
    ]
  ]
}

// ============================================
// EXAMPLE USAGE - Heavy Equipment Operator/Foreman
// ============================================
// Copy the section below and customize with YOUR information
// ============================================

#show: professional_resume.with(
  name: "David Chen",
  trade: "Heavy Equipment Operator / Foreman",
  phone: "(555) 345-6789",
  email: "david.chen@email.com",
  location: "Denver, CO",
  license: "CDL Class A",
  linkedin: "linkedin.com/in/davidchen",
  
  summary: [
    Highly skilled Heavy Equipment Operator with 15+ years of experience operating excavators, bulldozers, graders, loaders, and various heavy machinery on commercial and residential construction sites. Proven expertise in site preparation, grading, excavation, and material handling. Strong safety record with comprehensive knowledge of OSHA regulations and equipment maintenance protocols. Experienced in supervising teams and coordinating equipment operations for large-scale construction projects valued up to $10M.
  ],
  
  technical_skills: (
    "Excavator operation (up to 50-ton)",
    "Bulldozer & grader operation",
    "Front-end loader & backhoe",
    "Crane operation & rigging",
    "GPS & laser-guided grading systems",
    "Site surveying & grade checking",
    "Heavy equipment maintenance",
    "Blueprint & site plan reading",
  ),
  
  safety_certs: (
    "OSHA 30-Hour Construction",
    "NCCCO Crane Operator",
    "CDL Class A with endorsements",
    "First Aid/CPR/AED",
    "Fall Protection Competent Person",
    "Hazmat Awareness Training",
    "Trench Safety & Excavation",
  ),
  
  experience: (
    (
      title: "Senior Equipment Operator / Site Foreman",
      company: "Rocky Mountain Construction Group",
      location: "Denver, CO",
      dates: "March 2017 - Present",
      responsibilities: (
        "Supervise team of 12 equipment operators and laborers on commercial construction sites, ensuring safety compliance and project timelines",
        "Operate heavy equipment including 45-ton excavators, D8 bulldozers, and motor graders for site preparation and grading operations",
        "Coordinate with project managers and engineers to execute excavation and grading plans for projects valued up to $10M",
        "Reduced equipment downtime by 30% through implementation of preventive maintenance schedule",
        "Train new operators on equipment operation, safety protocols, and company standards - 8 operators trained",
        "Maintained zero lost-time accidents over 7 years while managing high-risk operations",
        "Achieved 98% on-time project completion rate through efficient equipment scheduling and operation",
      ),
    ),
    (
      title: "Heavy Equipment Operator",
      company: "Mountain States Excavation",
      location: "Denver, CO",
      dates: "June 2012 - February 2017",
      responsibilities: (
        "Operated various heavy equipment including excavators, loaders, dozers, and graders on residential and commercial projects",
        "Performed precision excavation and grading work for foundations, utilities, and roadway construction",
        "Completed 200+ excavation projects with 100% accuracy in grade specifications",
        "Conducted daily equipment inspections and performed routine maintenance to ensure optimal performance",
        "Collaborated with survey crews to achieve precise grade elevations within ±0.1 foot tolerance",
        "Operated GPS-guided grading systems for highway and large commercial projects",
      ),
    ),
    (
      title: "Equipment Operator",
      company: "Denver Site Development Inc.",
      location: "Denver, CO",
      dates: "April 2009 - May 2012",
      responsibilities: (
        "Operated skid steers, backhoes, mini excavators, and compaction equipment for residential site work",
        "Performed trenching operations for utility installations including water, sewer, and electrical lines",
        "Assisted senior operators with large equipment operations and learned advanced techniques",
        "Maintained detailed daily logs of equipment hours, fuel consumption, and maintenance needs",
      ),
    ),
  ),
  
  certifications: (
    (name: "CDL Class A License", issuer: "Colorado DMV", date: "2009"),
    (name: "NCCCO Mobile Crane Operator", issuer: "National Commission for Certification of Crane Operators", date: "2018"),
    (name: "OSHA 30-Hour Construction Safety", issuer: "OSHA Training Institute", date: "2016"),
    (name: "Certified Equipment Operator", issuer: "National Center for Construction Education & Research", date: "2015"),
    (name: "Excavation Competent Person", issuer: "IVES Training Group", date: "2019"),
  ),
  
  education: (
    (
      degree: "Heavy Equipment Operations Certificate",
      institution: "Colorado School of Trades",
      location: "Denver, CO",
      year: "2009",
    ),
    (
      degree: "Advanced Equipment Operations Training",
      institution: "Associated General Contractors of Colorado",
      location: "Denver, CO",
      year: "2014",
    ),
  ),
  
  safety_record: "15 years, 28,000+ operational hours with ZERO lost-time accidents and ZERO equipment damage incidents",
  
  achievements: (
    "Foreman of the Year Award - Rocky Mountain Construction Group (2020, 2023)",
    "Operated equipment on 150+ projects totaling over $50M in construction value",
    "Achieved 99.8% first-time grade accuracy on GPS-guided grading projects",
    "Reduced project equipment costs by 18% through efficient operation and fuel management",
    "Perfect safety inspection record - 60 consecutive OSHA inspections with zero violations",
    "Trained and mentored 15+ junior operators, with 12 advancing to senior operator positions",
  ),
  
  // Optional: Customize colors
  primary_color: rgb("#1a1a1a"),
  accent_color: rgb("#4a4a4a"),
)

// ============================================
// CUSTOMIZATION INSTRUCTIONS
// ============================================
// 1. Replace the example data above with YOUR information
// 2. Keep the same structure and format
// 3. LinkedIn field is optional but recommended for this template
// 4. Highlight supervisory and leadership experience
// 5. Emphasize project values and team sizes
// 6. Show cost savings and efficiency improvements
// 7. Optional: Change colors:
//    - primary_color: Main header background color
//    - accent_color: Secondary text highlights
//    - Try: rgb("#2c3e50") for blue-gray
//           rgb("#34495e") for darker gray
//           rgb("#1c4587") for professional blue
// 8. Save this file with a .typ extension
// 9. Compile using: typst compile yourfile.typ output.pdf
//    Or use the Typst web app at https://typst.app
// ============================================