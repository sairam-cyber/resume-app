// ============================================
// BOLD TEMPLATE - Blue-Collar Resume
// ============================================
// Strong visual impact with bold design elements
// Perfect for: Standing out, competitive markets, confident professionals
// Font: Arial | Layout: Single column with bold borders
// ATS Score: 3/5 - Good (use for direct applications)
// ============================================

#let bold_resume(
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
  
  // Color scheme (optional - can be customized)
  accent_color: rgb("#c0392b"),
) = {
  
  // Page setup
  set page(
    paper: "us-letter",
    margin: (left: 0.5in, right: 0.5in, top: 0.4in, bottom: 0.5in),
  )
  
  set text(
    font: "Arial",
    size: 10pt,
    lang: "en",
  )
  
  set par(justify: true, leading: 0.65em)
  
  // ============================================
  // HEADER - Bold and attention-grabbing
  // ============================================
  
  block(
    width: 100%,
    fill: accent_color,
    inset: 15pt,
  )[
    #align(center)[
      #text(
        size: 28pt, 
        weight: "black", 
        fill: white,
      )[#upper(name)] \
      #v(0.2em)
      #text(
        size: 14pt, 
        weight: "bold", 
        fill: white,
      )[#upper(trade)]
    ]
  ]
  
  // Contact strip
  #block(
    width: 100%,
    fill: black,
    inset: 10pt,
  )[
    #align(center)[
      #text(size: 10pt, fill: white, weight: "bold")[
        #phone #h(1.5em) | #h(1.5em) #email #h(1.5em) | #h(1.5em) #location
        #if license != "" [ #h(1.5em) | #h(1.5em) #license]
      ]
    ]
  ]
  
  #v(0.5em)
  
  // ============================================
  // PROFESSIONAL SUMMARY - Bold box
  // ============================================
  if summary != [] [
    #block(
      width: 100%,
      fill: rgb("#2c2c2c"),
      inset: 12pt,
    )[
      #text(size: 12pt, weight: "black", fill: accent_color)[▮ PROFESSIONAL SUMMARY]
      #v(0.3em)
      #text(fill: white)[#summary]
    ]
    #v(0.5em)
  ]
  
  // ============================================
  // CORE COMPETENCIES - Two-column bold layout
  // ============================================
  if technical_skills.len() > 0 or safety_certs.len() > 0 [
    #text(size: 13pt, weight: "black", fill: accent_color)[▮ CORE COMPETENCIES]
    #v(0.3em)
    
    #grid(
      columns: 2,
      column-gutter: 1em,
      
      // Left: Technical Skills
      block(
        width: 100%,
        fill: rgb("#f5f5f5"),
        inset: 10pt,
        stroke: 3pt + accent_color,
      )[
        #text(weight: "black", size: 11pt)[TECHNICAL SKILLS]
        #v(0.2em)
        #for skill in technical_skills [
          ▸ #text(weight: "semibold")[#skill] \
        ]
      ],
      
      // Right: Safety Certifications
      block(
        width: 100%,
        fill: rgb("#f5f5f5"),
        inset: 10pt,
        stroke: 3pt + accent_color,
      )[
        #text(weight: "black", size: 11pt)[SAFETY & COMPLIANCE]
        #v(0.2em)
        #for cert in safety_certs [
          ▸ #text(weight: "semibold")[#cert] \
        ]
      ],
    )
    #v(0.5em)
  ]
  
  // ============================================
  // PROFESSIONAL EXPERIENCE
  // ============================================
  if experience.len() > 0 [
    #text(size: 13pt, weight: "black", fill: accent_color)[▮ PROFESSIONAL EXPERIENCE]
    #v(0.3em)
    
    #for job in experience [
      #block(
        width: 100%,
        inset: (left: 8pt, rest: 0pt),
        stroke: (left: 4pt + accent_color),
      )[
        #grid(
          columns: (1fr, auto),
          [#text(weight: "black", size: 12pt)[#job.title]],
          [#text(weight: "bold", style: "italic", fill: accent_color)[#job.dates]]
        )
        #text(weight: "bold", size: 10pt)[#job.company] | #job.location
        #v(0.25em)
        
        #for duty in job.responsibilities [
          ▸ #duty \
        ]
        #v(0.4em)
      ]
    ]
  ]
  
  // ============================================
  // BOTTOM SECTION - Three columns
  // ============================================
  
  #grid(
    columns: 3,
    column-gutter: 0.8em,
    row-gutter: 0.5em,
    
    // CERTIFICATIONS
    if certifications.len() > 0 [
      #block(
        width: 100%,
        fill: rgb("#f9f9f9"),
        inset: 8pt,
        stroke: 2pt + black,
      )[
        #text(size: 10pt, weight: "black")[CERTIFICATIONS]
        #v(0.2em)
        #for cert in certifications [
          #text(weight: "bold", size: 8.5pt)[#cert.name] \
          #text(size: 7.5pt)[#cert.issuer] \
          #if "date" in cert [
            #text(size: 7.5pt, style: "italic")[#cert.date]
          ]
          #v(0.15em)
        ]
      ]
    ] else [],
    
    // EDUCATION
    if education.len() > 0 [
      #block(
        width: 100%,
        fill: rgb("#f9f9f9"),
        inset: 8pt,
        stroke: 2pt + black,
      )[
        #text(size: 10pt, weight: "black")[EDUCATION]
        #v(0.2em)
        #for edu in education [
          #text(weight: "bold", size: 8.5pt)[#edu.degree] \
          #text(size: 7.5pt)[#edu.institution] \
          #text(size: 7.5pt, style: "italic")[#edu.year] \
          #v(0.15em)
        ]
      ]
    ] else [],
    
    // SAFETY RECORD
    if safety_record != "" [
      #block(
        width: 100%,
        fill: rgb("#27ae60"),
        inset: 8pt,
        stroke: 2pt + black,
      )[
        #text(size: 10pt, weight: "black", fill: white)[SAFETY RECORD]
        #v(0.2em)
        #text(size: 8.5pt, fill: white, weight: "bold")[#safety_record]
      ]
    ] else [],
  )
  
  // ============================================
  // ACHIEVEMENTS - Bold highlight box
  // ============================================
  if achievements.len() > 0 [
    #v(0.5em)
    #block(
      width: 100%,
      fill: rgb("#fff3cd"),
      inset: 10pt,
      stroke: 3pt + rgb("#ffc107"),
    )[
      #text(size: 12pt, weight: "black")[🏆 KEY ACHIEVEMENTS]
      #v(0.3em)
      #for achievement in achievements [
        ▸ #text(weight: "semibold")[#achievement] \
      ]
    ]
  ]
}

// ============================================
// EXAMPLE USAGE - Certified Welder Resume
// ============================================
// Copy the section below and customize with YOUR information
// ============================================

#show: bold_resume.with(
  name: "Marcus Rodriguez",
  trade: "Certified Welder / Fabricator",
  phone: "(555) 678-9012",
  email: "marcus.rodriguez@email.com",
  location: "Pittsburgh, PA",
  license: "AWS Certified Welder",
  
  summary: [
    Highly skilled Certified Welder with 9 years of experience in structural steel fabrication, pipe welding, and custom metalwork. Expert in MIG, TIG, Stick, and Flux-Core welding processes for carbon steel, stainless steel, and aluminum. AWS certified with proven ability to read blueprints, interpret welding symbols, and produce high-quality welds that pass rigorous inspection standards. Strong safety record and commitment to precision craftsmanship on industrial, commercial, and construction projects.
  ],
  
  technical_skills: (
    "MIG, TIG, Stick & Flux-Core welding",
    "Structural steel fabrication",
    "Pipe welding (all positions)",
    "Blueprint reading & interpretation",
    "Welding symbol understanding",
    "Oxy-acetylene cutting & brazing",
    "Metal fabrication & layout",
    "Grinding & finishing techniques",
  ),
  
  safety_certs: (
    "OSHA 30-Hour Construction",
    "Welding fume awareness",
    "Hot work permits certified",
    "Confined space entry",
    "Fall protection training",
    "First Aid/CPR certified",
    "Respiratory protection fit test",
  ),
  
  experience: (
    (
      title: "Lead Welder / Fabricator",
      company: "Steel City Industrial Fabrication",
      location: "Pittsburgh, PA",
      dates: "August 2019 - Present",
      responsibilities: (
        "Lead welding team of 6 welders on structural steel projects valued up to $2M",
        "Perform complex welding operations including multi-position pipe welding and structural steel connections",
        "Achieved 98% weld pass rate on ultrasonic and X-ray inspections across 300+ welds",
        "Read and interpret blueprints, engineering drawings, and welding procedure specifications (WPS)",
        "Fabricate custom steel structures including platforms, stairs, handrails, and support systems",
        "Train and mentor junior welders on proper welding techniques and safety procedures",
        "Reduced material waste by 20% through improved layout and cutting procedures",
        "Zero welding defects on critical pressure vessel projects totaling 500+ welds",
      ),
    ),
    (
      title: "Certified Welder",
      company: "Keystone Construction & Welding",
      location: "Pittsburgh, PA",
      dates: "May 2016 - July 2019",
      responsibilities: (
        "Performed structural welding on commercial construction projects including buildings and bridges",
        "Completed 1,000+ certified welds with 95% first-time pass rate on visual inspections",
        "Operated welding equipment in shop and field environments in all weather conditions",
        "Welded carbon steel, stainless steel, and aluminum using appropriate filler materials and techniques",
        "Maintained and troubleshot welding equipment ensuring minimal downtime",
        "Adhered to all AWS D1.1 structural welding code requirements",
      ),
    ),
  ),
  
  certifications: (
    (name: "AWS Certified Welder - SMAW, GMAW, GTAW", issuer: "American Welding Society", date: "2018 (Current)"),
    (name: "Certified Welding Inspector (CWI) - In Progress", issuer: "AWS", date: "Expected 2025"),
    (name: "6G Pipe Welding Certification", issuer: "AWS", date: "2019"),
    (name: "Structural Steel Welding D1.1", issuer: "AWS", date: "2017"),
    (name: "OSHA 30-Hour Construction", issuer: "OSHA", date: "2016"),
  ),
  
  education: (
    (
      degree: "Welding Technology Diploma",
      institution: "Bidwell Training Center",
      location: "Pittsburgh, PA",
      year: "2015",
    ),
    (
      degree: "Advanced Pipe Welding Certificate",
      institution: "Hobart Institute of Welding",
      location: "Troy, OH",
      year: "2018",
    ),
  ),
  
  safety_record: "9 years, 18,000+ hours with ZERO lost-time incidents and ZERO burn injuries",
  
  achievements: (
    "Welder of the Year Award - Steel City Industrial Fabrication (2022, 2024)",
    "Perfect weld inspection record on $5M bridge construction project (2023)",
    "Completed 3,000+ certified welds with 97% cumulative pass rate",
    "Certified in 15 different welding procedures including exotic materials",
    "Reduced rework costs by 35% through improved quality control measures",
    "Mentored 8 apprentice welders, with 7 achieving AWS certification",
  ),
  
  // Optional: Customize accent color
  accent_color: rgb("#c0392b"),  // Default: Bold red
)

// ============================================
// CUSTOMIZATION INSTRUCTIONS
// ============================================
// 1. Replace the example data above with YOUR information
// 2. This template is designed to STAND OUT and make IMPACT
// 3. Bold colors and borders grab attention immediately
// 4. Use ▸ triangular bullets for modern look
// 5. Keep content strong and achievement-focused
// 6. Optional: Change accent color to match your style:
//    - accent_color: rgb("#c0392b")  // Default: Bold Red
//    - Try these alternatives:
//      * Industrial Blue: rgb("#2980b9")
//      * Power Orange: rgb("#d35400")
//      * Dark Steel: rgb("#34495e")
//      * Electric Green: rgb("#27ae60")
//      * Deep Purple: rgb("#8e44ad")
// 7. Perfect for:
//    - Hand-delivering to hiring managers
//    - Career fairs and networking events
//    - Direct applications (not online ATS systems)
//    - Small to medium companies
//    - Competitive job markets
//    - When you want to be remembered
// 8. Best trades for Bold template:
//    - Welders, Fabricators, Metalworkers
//    - Construction trades (Ironworker, Carpenter)
//    - Heavy equipment operators
//    - Mechanics (Auto, Diesel, Heavy)
//    - Industrial maintenance
//    - Any trade where confidence matters
// 9. DO NOT use for:
//    - Large corporate ATS systems (use Simple instead)
//    - Very conservative companies (use Classic instead)
//    - Government jobs (use Professional instead)
// 10. Save this file with a .typ extension
// 11. Compile using: typst compile yourfile.typ output.pdf
//     Or use the Typst web app at https://typst.app
//
// REMEMBER: This template is about CONFIDENCE and IMPACT.
// You're not just another resume in the pile - you're THE candidate
// they need to interview. Make every word count!
// ============================================