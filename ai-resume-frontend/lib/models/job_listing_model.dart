// lib/models/job_listing_model.dart
import 'package:flutter/material.dart';

class JobListingModel {
  final String id;
  final String role;
  final String location;
  final String salary;
  final String openings;
  final String description;
  final DateTime createdAt;
  final String orgName;
  final IconData logo;
  final bool isWorkFromHome; // <-- ADDED
  final String jobType;      // <-- ADDED ('Full-time' or 'Part-time')

  JobListingModel({
    required this.id,
    required this.role,
    required this.location,
    required this.salary,
    required this.openings,
    required this.description,
    required this.createdAt,
    required this.orgName,
    this.logo = Icons.apartment,
    this.isWorkFromHome = false, // <-- ADDED default
    this.jobType = 'Full-time', // <-- ADDED default
  });

  factory JobListingModel.fromJson(Map<String, dynamic> json) {
    // Helper to get org name
    String orgName = 'Unknown Company';
    if (json['organization'] != null && json['organization'] is Map) {
      orgName = json['organization']['orgName'] ?? orgName;
    }

    // Helper to assign logo based on role
    IconData logo = Icons.work_outline_rounded;
    String role = json['role']?.toLowerCase() ?? '';
    if (role.contains('driver')) {
      logo = Icons.local_shipping;
    } else if (role.contains('electrician')) {
      logo = Icons.electrical_services;
    } else if (role.contains('cook')) {
      logo = Icons.restaurant;
    } else if (role.contains('security')) {
      logo = Icons.security;
    }

    // --- NEW: Handle jobType and isWorkFromHome ---
    // Assuming backend might not send these yet, provide defaults
    String jobType = json['jobType'] ?? 'Full-time';
    bool isWorkFromHome = json['isWorkFromHome'] ?? false;
    // --- END NEW ---

    return JobListingModel(
      id: json['_id'] ?? '', // <-- Ensure ID is handled correctly
      role: json['role'] ?? 'No Role',
      location: json['location'] ?? 'No Location',
      salary: json['salary'] ?? 'Not specified',
      openings: json['openings']?.toString() ?? '1', // <-- Ensure openings is String
      description: json['description'] ?? 'No description provided.',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()), // <-- Handle potential null createdAt
      orgName: orgName,
      logo: logo,
      isWorkFromHome: isWorkFromHome, // <-- ADDED
      jobType: jobType,            // <-- ADDED
    );
  }
}