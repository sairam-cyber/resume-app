import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rezume_app/providers/language_provider.dart';
import 'package:rezume_app/app/localization/app_localizations.dart';

class LanguageSelectorWidget extends StatelessWidget {
  const LanguageSelectorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final loc = AppLocalizations.of(context);

    return PopupMenuButton<String>(
      icon: const Icon(Icons.language),
      tooltip: loc?.translate('choose_language') ?? 'Choose Language',
      onSelected: (String languageCode) {
        languageProvider.changeLanguage(Locale(languageCode));
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
          value: 'en',
          child: Row(
            children: [
              if (languageProvider.appLocale.languageCode == 'en')
                const Icon(Icons.check, color: Colors.blue),
              if (languageProvider.appLocale.languageCode == 'en')
                const SizedBox(width: 8),
              Text(loc?.translate('language_english') ?? 'English'),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'hi',
          child: Row(
            children: [
              if (languageProvider.appLocale.languageCode == 'hi')
                const Icon(Icons.check, color: Colors.blue),
              if (languageProvider.appLocale.languageCode == 'hi')
                const SizedBox(width: 8),
              Text(loc?.translate('language_hindi') ?? 'हिंदी'),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'or',
          child: Row(
            children: [
              if (languageProvider.appLocale.languageCode == 'or')
                const Icon(Icons.check, color: Colors.blue),
              if (languageProvider.appLocale.languageCode == 'or')
                const SizedBox(width: 8),
              Text(loc?.translate('language_odia') ?? 'ଓଡ଼ିଆ'),
            ],
          ),
        ),
      ],
    );
  }
}
