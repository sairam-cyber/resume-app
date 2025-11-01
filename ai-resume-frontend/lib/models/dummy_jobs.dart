// lib/models/dummy_jobs.dart

import 'package:flutter/material.dart';

class SearchableJob {
  final int id;
  final String role;
  final String companyName;
  final String location;
  final int experienceRequired; // in years
  final int salaryMin; // annual INR
  final int salaryMax; // annual INR
  final String jobType; // 'Full-time' or 'Part-time'
  final bool isWorkFromHome;
  final String description;
  final List<String> tags;
  final String postedAgo;
  final IconData logo;

  SearchableJob({
    required this.id,
    required this.role,
    required this.companyName,
    required this.location,
    required this.experienceRequired,
    required this.salaryMin,
    required this.salaryMax,
    required this.jobType,
    required this.isWorkFromHome,
    required this.description,
    required this.tags,
    required this.postedAgo,
    required this.logo,
  });
}

// A list of 50 dummy jobs for users to search
final List<SearchableJob> dummyJobs = List.generate(50, (index) {
  final jobProfiles = [
    'Driver',
    'Electrician',
    'Plumber',
    'Cook',
    'Security Guard',
    'Welder',
    'Carpenter',
    'Mechanic'
  ];
  final companies = [
    'Larsen & Toubro',
    'Tata Motors',
    'Blue Star',
    'Taj Hotels',
    'G4S Security',
    'Adani Ports',
    'Urban Company',
    'Mahindra'
  ];
  final locations = [
    'Mumbai',
    'Delhi',
    'Bangalore',
    'Rourkela',
    'Kolkata',
    'Chennai',
    'Hyderabad',
    'Pune'
  ];
  final logos = [
    Icons.apartment,
    Icons.local_shipping,
    Icons.engineering,
    Icons.hotel,
    Icons.security,
    Icons.waves,
    Icons.home_repair_service,
    Icons.car_repair
  ];

  final job = jobProfiles[index % jobProfiles.length];
  final company = companies[index % companies.length];
  final logo = logos[index % logos.length];
  final exp = (index % 10); // 0 to 9 years experience
  final minSal = (index % 6 + 2) * 100000; // 2,00,000 to 7,00,000

  List<String> tags = [];
  switch (job) {
    case 'Driver':
      tags = ['LMV License', 'Defensive Driving', 'Route Navigation'];
      break;
    case 'Electrician':
      tags = ['Wiring', 'Troubleshooting', 'Safety Compliance'];
      break;
    case 'Plumber':
      tags = ['Pipe Fitting', 'Drainage Systems', 'Leak Repair'];
      break;
    case 'Cook':
      tags = ['Indian Cuisine', 'Food Safety', 'Kitchen Management'];
      break;
    default:
      tags = ['General Maintenance', 'Safety Procedures'];
      break;
  }

  return SearchableJob(
    id: index + 1,
    role: job,
    companyName: company,
    logo: logo,
    location: locations[index % locations.length],
    experienceRequired: exp,
    salaryMin: minSal,
    salaryMax: minSal + 150000,
    jobType: (index % 3 == 0) ? 'Part-time' : 'Full-time',
    isWorkFromHome: (index % 5 == 0), // 1 in 5 are WFH
    description:
        'Conduct interactive 1:1 demo and regular online classes for the specified role. Looking for candidates with strong skills in ${tags.join(", ")}.',
    tags: tags,
    postedAgo: '${(index % 7) + 1} days ago',
  );
});