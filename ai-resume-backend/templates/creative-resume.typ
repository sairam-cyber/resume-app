// ============================================
// CREATIVE TEMPLATE - Blue-Collar Resume
// ============================================
// Unique two-column layout with creative visual elements
// Perfect for: Younger workers, creative trades, modern companies
// Font: Open Sans | Layout: Two-column (sidebar + main)
// ATS Score: 3/5 - Good (prioritize content over visuals)
// ============================================

#let creative_resume(
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
  primary_color: rgb("#e67e22"),
  secondary_color: rgb("#34495e")
) = {
  // Page setup
  #set page(
    paper: "us-letter",
    margin: (left: 0.5in, right: 0.5in, top: 0.5in, bottom: 0.5in),
  )

  #set text(
    font: "Open Sans",
    size: 10pt,
    lang: "en",
  )

  #set par(justify: true, leading: 0.65em)

  // ============================================
  // HEADER - Creative asymmetric design
  // ============================================

  #grid(
    columns: (auto, 1fr),
    column-gutter: 1em,

    // Left side - Vertical name bar
    block(
      fill: primary_color,
      inset: 10pt,
      radius: (left: 5pt, right: 0pt),
    )[
      #text(
        size: 26pt,
        weight: "bold",
        fill: white,
      )[
        #rotate(-90deg)[#name]
      ]
    ],

    // Right side - Info
    block[
      #text(size: 18pt, weight: "bold", fill: secondary_color)[#trade]
      #v(0.5em)

      #grid(
        columns: (auto, auto),
        row-gutter: 0.3em,
        column-gutter: 1.5em,

        [📱], [#phone],
        [✉], [#email],
        [📍], [#location],
        ..if license != "" {
          ([🎫], [#license])
        } else {
          ()
        }
      )
    ]
  )

  #v(0.5em)
  #line(length: 100%, stroke: 2pt + primary_color)
  #v(0.5em)

  // ============================================
  // TWO-COLUMN LAYOUT
  // ============================================

  #grid(
    columns: (1fr, 2fr),
    column-gutter: 1.2em,

    // ==================== LEFT COLUMN ====================
    [
      // SKILLS
      #if technical_skills.len() > 0 [
        #block(
          fill: rgb("#ecf0f1"),
          inset: 10pt,
          radius: 5pt,
          width: 100%,
        )[
          #text(size: 11pt, weight: "bold", fill: secondary_color)[💡 TECHNICAL SKILLS]
          #v(0.3em)
          #for skill in technical_skills [
            • #text(size: 9pt)[#skill] \
          ]
        ]
        #v(0.5em)
      ]

      // SAFETY CERTIFICATIONS
      #if safety_certs.len() > 0 [
        #block(
          fill: rgb("#d5f4e6"),
          inset: 10pt,
          radius: 5pt,
          width: 100%,
        )[
          #text(size: 11pt, weight: "bold", fill: rgb("#27ae60"))[🛡 SAFETY CERTS]
          #v(0.3em)
          #for cert in safety_certs [
            • #text(size: 9pt)[#cert] \
          ]
        ]
        #v(0.5em)
      ]

      // CERTIFICATIONS
      #if certifications.len() > 0 [
        #block(
          fill: rgb("#fff3e0"),
          inset: 10pt,
          radius: 5pt,
          width: 100%,
        )[
          #text(size: 11pt, weight: "bold", fill: primary_color)[🎓 CERTIFICATIONS]
          #v(0.3em)
          #for cert in certifications [
            #text(weight: "semibold", size: 9pt)[#cert.name] \
            #text(size: 8pt, style: "italic")[#cert.issuer] \
            #if "date" in cert [
              #text(size: 8pt)[#cert.date]
            ]
            #v(0.2em)
          ]
        ]
        #v(0.5em)
      ]

      // EDUCATION
      #if education.len() > 0 [
        #block(
          fill: rgb("#e3f2fd"),
          inset: 10pt,
          radius: 5pt,
          width: 100%,
        )[
          #text(size: 11pt, weight: "bold", fill: rgb("#1976d2"))[🎓 EDUCATION]
          #v(0.3em)
          #for edu in education [
            #text(weight: "semibold", size: 9pt)[#edu.degree] \
            #text(size: 8pt)[#edu.institution] \
            #text(size: 8pt, style: "italic")[#edu.year] \
            #v(0.2em)
          ]
        ]
        #v(0.5em)
      ]

      // SAFETY RECORD
      #if safety_record != "" [
        #block(
          fill: rgb("#c8e6c9"),
          inset: 10pt,
          radius: 5pt,
          width: 100%,
        )[
          #text(size: 10pt, weight: "bold", fill: rgb("#2e7d32"))[✓ SAFETY RECORD] \
          #v(0.2em)
          #text(size: 9pt)[#safety_record]
        ]
      ]
    ],

    // ==================== RIGHT COLUMN ====================
    [
      // PROFESSIONAL SUMMARY
      #if summary != [] [
        #text(size: 12pt, weight: "bold", fill: secondary_color)[👤 ABOUT ME]
        #v(0.3em)
        #block(
          fill: rgb("#f8f9fa"),
          inset: 10pt,
          radius: 5pt,
        )[
          #summary
        ]
        #v(0.5em)
      ]

      // WORK EXPERIENCE
      #if experience.len() > 0 [
        #text(size: 12pt, weight: "bold", fill: secondary_color)[💼 EXPERIENCE]
        #v(0.3em)

        #for (index, job) in experience.enumerate() [
          #block[
            // Timeline dot
            #grid(
              columns: (auto, 1fr),
              column-gutter: 0.8em,

              // Dot and line
              block(width: 12pt)[
                #circle(radius: 6pt, fill: primary_color)
                #if index < experience.len() - 1 [
                  #place(
                    dx: 6pt - 1pt,
                    dy: 12pt,
                  )[
                    #line(length: 100%, angle: 90deg, stroke: 2pt + primary_color)
                  ]
                ]
              ],

              // Content
              block[
                #grid(
                  columns: (1fr, auto),
                  [#text(weight: "bold", size: 11pt, fill: secondary_color)[#job.title]],
                  [#text(size: 9pt, style: "italic", fill: primary_color)[#job.dates]]
                )
                #text(weight: "semibold", size: 10pt)[#job.company] | #text(size: 9pt)[#job.location]
                #v(0.2em)

                #for duty in job.responsibilities [
                  ▸ #text(size: 9.5pt)[#duty] \
                ]
                #v(0.4em)
              ]
            )
          ]
        ]
      ]

      // ACHIEVEMENTS
      #if achievements.len() > 0 [
        #v(0.3em)
        #text(size: 12pt, weight: "bold", fill: secondary_color)[🏆 ACHIEVEMENTS]
        #v(0.3em)

        #block(
          fill: rgb("#fff9c4"),
          inset: 10pt,
          radius: 5pt,
        )[
          #for achievement in achievements [
            ⭐ #text(size: 9.5pt)[#achievement] \
          ]
        ]
      ]
    ]
  )
}

// ============================================
// EXAMPLE USAGE
// ============================================
// The app extracts only the function above;
// this section is a marker for parsing.
// #show: creative_resume.with(
//   name: "Alex Worker",
//   trade: "Electrician",
// )

// ============================================
// CUSTOMIZATION INSTRUCTIONS
// ============================================
// Colors: primary_color, secondary_color.
// Provide arrays for skills, certs, experience, education, and achievements.