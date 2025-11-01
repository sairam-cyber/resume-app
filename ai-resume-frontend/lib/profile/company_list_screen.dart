import 'package:flutter/material.dart';

class CompanyListScreen extends StatelessWidget {
  const CompanyListScreen({super.key});

  // Dummy data for companies
  final List<Map<String, dynamic>> _companies = const [
    {
      'name': 'Larsen & Toubro Ltd',
      'location': 'Bhubaneswar, Odisha',
      'roles': ['Driver', 'Electrician', 'Welder'],
      'logo': Icons.apartment,
      'description': 'Leading engineering and construction company.',
      'openings': 15,
      'type': 'Construction',
      'salary': '₹18,000 - ₹25,000',
    },
    {
      'name': 'Tata Motors Transport',
      'location': 'Cuttack, Odisha',
      'roles': ['Driver', 'Mechanic'],
      'logo': Icons.local_shipping,
      'description': 'Premier automotive and logistics company.',
      'openings': 8,
      'type': 'Automotive & Transport',
      'salary': '₹20,000 - ₹30,000',
    },
    {
      'name': 'Blue Star Limited',
      'location': 'Puri, Odisha',
      'roles': ['AC Technician', 'Electrician'],
      'logo': Icons.engineering,
      'description': 'Leading air conditioning and commercial refrigeration company.',
      'openings': 12,
      'type': 'HVAC & Maintenance',
      'salary': '₹15,000 - ₹22,000',
    },
    {
      'name': 'Taj Hotels Group',
      'location': 'Bhubaneswar, Odisha',
      'roles': ['Cook', 'Security Guard', 'Housekeeping'],
      'logo': Icons.hotel,
      'description': 'Luxury hotel chain with multiple properties.',
      'openings': 20,
      'type': 'Hospitality',
      'salary': '₹16,000 - ₹25,000',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Openings'),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        titleTextStyle: const TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _companies.length,
        itemBuilder: (context, index) {
          final company = _companies[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: InkWell(
              onTap: () {
                // Show application confirmation
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Apply to ${company['name']}'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Role: ${(company['roles'] as List).join(", ")}'),
                        const SizedBox(height: 8),
                        Text('Salary: ${company['salary']}'),
                        const SizedBox(height: 8),
                        Text('Location: ${company['location']}'),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      FilledButton(
                        onPressed: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Application submitted successfully!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        },
                        child: const Text('Apply Now'),
                      ),
                    ],
                  ),
                );
              },
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            company['logo'] as IconData,
                            color: Colors.blue.shade700,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                company['name'] as String,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${company['type']} • ${company['location']}',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      company['description'] as String,
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Salary: ${company["salary"]}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: (company['roles'] as List)
                                .map((role) => Chip(
                                      label: Text(
                                        role as String,
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                      backgroundColor: Colors.grey[100],
                                    ))
                                .toList(),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${company['openings']} openings',
                            style: TextStyle(
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}