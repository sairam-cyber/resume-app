import 'package:flutter/material.dart';
import 'payment_page.dart';

// A simple data model for our subscription plans
class SubscriptionPlan {
  final String title;
  final String price;
  final String billingCycle;
  final List<String> perks;

  SubscriptionPlan({
    required this.title,
    required this.price,
    required this.billingCycle,
    required this.perks,
  });
}

// Main page widget
class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage({super.key});

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  // --- CHANGED: Updated plans and perks for Organizations ---
  final List<SubscriptionPlan> plans = [
    SubscriptionPlan(
      title: 'Basic Hirer',
      price: '₹299',
      billingCycle: '/ month',
      perks: [
        'Post up to 5 job listings',
        'Access to candidate database',
        'Basic candidate search filters',
        'Standard company profile',
      ],
    ),
    SubscriptionPlan(
      title: 'Standard Hirer',
      price: '₹399',
      billingCycle: '/ month',
      perks: [
        'All features in Basic',
        'Post up to 15 job listings',
        'AI-Matched candidate suggestions',
        'Featured job listing (7 days)',
      ],
    ),
    SubscriptionPlan(
      title: 'Premium Hirer',
      price: '₹499',
      billingCycle: '/ month',
      perks: [
        'All features in Standard',
        'Unlimited job listings',
        'Premium job placements',
        'Access to verified candidates',
        'Dedicated account support',
      ],
    ),
  ];

  // --- CHANGED: Added a color list to match each plan ---
  final List<Color> planColors = [
    Colors.indigo,    // Color for Basic (₹299)
    Colors.teal,      // Color for Standard (₹399)
    Colors.deepPurple, // Color for Premium (₹499)
  ];

  // --- CHANGED: Default selection is now index 0 (Basic) ---
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    // --- CHANGED: Get the currently selected color ---
    final Color selectedColor = planColors[_selectedIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose a Plan'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: plans.length,
                itemBuilder: (context, index) {
                  final plan = plans[index];
                  final isSelected = _selectedIndex == index;

                  return PlanCard(
                    plan: plan,
                    isSelected: isSelected,
                    planColor: planColors[index], // --- CHANGED: Pass the plan's color
                    onTap: () {
                      setState(() {
                        _selectedIndex = index;
                      });
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: selectedColor,
                  minimumSize: const Size(double.infinity, 50),
                ),
                // --- MODIFIED THIS ---
                onPressed: () {
                  // Navigate to the new PaymentPage
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PaymentPage(
                        plan: plans[_selectedIndex],
                        planColor: selectedColor,
                      ),
                    ),
                  );
                },
                // --- END OF MODIFICATION ---
                child: Text(
                  'Get Started with ${plans[_selectedIndex].title}',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom widget for the Plan Card
class PlanCard extends StatelessWidget {
  const PlanCard({
    super.key,
    required this.plan,
    required this.isSelected,
    required this.onTap,
    required this.planColor, // --- CHANGED: Added planColor parameter
  });

  final SubscriptionPlan plan;
  final bool isSelected;
  final VoidCallback onTap;
  final Color planColor; // --- CHANGED: Store the plan's base color

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // --- CHANGED: All colors are now derived from planColor or theme defaults ---
    final Color cardColor =
        isSelected ? planColor.withOpacity(0.12) : colorScheme.surfaceContainerHighest;
    final Color borderColor = isSelected ? planColor : colorScheme.outline;
    final Color titleColor = isSelected ? planColor : colorScheme.onSurfaceVariant;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      color: cardColor, // --- CHANGED
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(
          color: borderColor, // --- CHANGED
          width: isSelected ? 2.0 : 1.0,
        ),
      ),
      child: InkWell(
        // The InkWell provides the ripple effect on tap
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                plan.title,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: titleColor, // --- CHANGED
                ),
              ),
              const SizedBox(height: 12.0),

              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    plan.price,
                    style: textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface, // Price is always dark
                    ),
                  ),
                  const SizedBox(width: 4.0),
                  Text(
                    plan.billingCycle,
                    style: textTheme.bodyMedium
                        ?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
              const Divider(height: 24.0),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: plan.perks
                    .map((perk) => PerkItem(
                          text: perk,
                          perkColor: planColor, // --- CHANGED
                          isSelected: isSelected, // --- CHANGED
                        ))
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Helper widget for the perk item (icon + text)
class PerkItem extends StatelessWidget {
  const PerkItem({
    super.key,
    required this.text,
    required this.perkColor, // --- CHANGED
    required this.isSelected, // --- CHANGED
  });

  final String text;
  final Color perkColor; // --- CHANGED
  final bool isSelected; // --- CHANGED

  @override
  Widget build(BuildContext context) {
    // --- CHANGED: Icon color depends on selection, text color is constant ---
    final colorScheme = Theme.of(context).colorScheme;
    final Color iconColor = isSelected ? perkColor : colorScheme.onSurfaceVariant;
    final Color textColor = colorScheme.onSurface;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 20.0,
            color: iconColor, // --- CHANGED
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: textColor, // --- CHANGED
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
