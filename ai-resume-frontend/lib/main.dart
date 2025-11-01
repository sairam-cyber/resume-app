// lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rezume_app/app/localization/app_localizations.dart';
import 'package:rezume_app/providers/language_provider.dart';
import 'package:rezume_app/screens/splash_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:rezume_app/home/home_screen.dart';
import 'package:rezume_app/templates/templates_screen.dart';
import 'package:rezume_app/subscription/subscription_page.dart';
import 'package:rezume_app/ats_checker/upload_resume_screen.dart';
import 'package:rezume_app/profile/profile_screen.dart';
// --- MODIFICATION: Removed CandidateListScreen, Added PostedJobsScreen ---
import 'package:rezume_app/profile/posted_jobs_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => LanguageProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ... (rest of build method is unchanged) ...
    final languageProvider = Provider.of<LanguageProvider>(context);

    return MaterialApp(
      title: 'Rezume App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      
      // --- LOCALIZATION SETTINGS ---
      locale: languageProvider.appLocale,
      supportedLocales: const [
        Locale('en', ''), // English
        Locale('hi', ''), // Hindi
        Locale('or', ''), // Odia
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      localeResolutionCallback: (locale, supportedLocales) {
        for (var supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == locale?.languageCode) {
            return supportedLocale;
          }
        }
        return supportedLocales.first;
      },
      // --- END LOCALIZATION SETTINGS ---

      home: const SplashScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  final String userRole;
  
  const MainScreen({super.key, this.userRole = 'User'});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // ... (initState and _navigateToTab are unchanged) ...
  bool _isOrganizationMode = false;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // Set initial mode based on userRole
    _isOrganizationMode = widget.userRole == 'Organization';
  }

  // Method to navigate to a specific tab
  void _navigateToTab(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // --- JOB SEEKER UI (unchanged) ---
  List<Widget> get _userPages => [
    HomeScreen(role: 'User', onNavigateToTab: _navigateToTab),
    const TemplatesScreen(),
    const UploadResumeScreen(),
    const ProfileScreen(role: 'User'),
  ];

  List<BottomNavigationBarItem> _getUserNavItems(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return [
      BottomNavigationBarItem(
        icon: Icon(Icons.home_outlined),
        activeIcon: Icon(Icons.home),
        label: loc?.translate('nav_home') ?? 'Home',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.article_outlined),
        activeIcon: Icon(Icons.article),
        label: loc?.translate('nav_templates') ?? 'Templates',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.score_outlined),
        activeIcon: Icon(Icons.score),
        label: loc?.translate('nav_ats_score') ?? 'ATS Score',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.person_outline),
        activeIcon: Icon(Icons.person),
        label: loc?.translate('nav_profile') ?? 'Profile',
      ),
    ];
  }

  // --- ORGANIZATION UI (MODIFIED) ---
  List<Widget> get _organizationPages => [
    HomeScreen(role: 'Organization', onNavigateToTab: _navigateToTab),
    const SubscriptionPage(),
    // --- THIS IS THE CHANGE ---
    PostedJobsScreen(themeColor: Colors.indigo.shade600),
    // --- END OF CHANGE ---
    const ProfileScreen(role: 'Organization'),
  ];

  List<BottomNavigationBarItem> _getOrgNavItems(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return [
      BottomNavigationBarItem(
        icon: Icon(Icons.home_outlined),
        activeIcon: Icon(Icons.home),
        label: loc?.translate('nav_home') ?? 'Home',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.subscriptions_outlined),
        activeIcon: Icon(Icons.subscriptions),
        label: loc?.translate('nav_subscription') ?? 'Subscription',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.work_outline_rounded),
        activeIcon: Icon(Icons.work_rounded),
        label: loc?.translate('nav_job') ?? 'Job',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.person_outline),
        activeIcon: Icon(Icons.person),
        label: loc?.translate('nav_profile') ?? 'Profile',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    // ... (rest of build method is unchanged) ...
    final bool isOrg = _isOrganizationMode;
    final List<Widget> currentPages = isOrg ? _organizationPages : _userPages;
    final List<BottomNavigationBarItem> currentNavItems = isOrg ? _getOrgNavItems(context) : _getUserNavItems(context);

    return Scaffold(
      body: currentPages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: currentNavItems,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        selectedItemColor: Colors.indigo,
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}