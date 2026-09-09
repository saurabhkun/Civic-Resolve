import 'package:flutter/material.dart';
import 'language_service.dart';

class LanguageDropdown extends StatefulWidget {
  const LanguageDropdown({super.key});

  @override
  State<LanguageDropdown> createState() => _LanguageDropdownState();
}

class _LanguageDropdownState extends State<LanguageDropdown> {
  final LanguageService _languageService = LanguageService();

  @override
  void initState() {
    super.initState();
    _languageService.addListener(_onLanguageChanged);
  }

  @override
  void dispose() {
    _languageService.removeListener(_onLanguageChanged);
    super.dispose();
  }

  void _onLanguageChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF3B82F6), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Language>(
          value: _languageService.currentLanguage,
          icon: const Icon(
            Icons.expand_more,
            color: Color(0xFF3B82F6),
            size: 24,
          ),
          style: const TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(16),
          elevation: 12,
          menuMaxHeight: 320,
          itemHeight: 64, // Larger touch targets
          items: LanguageService.supportedLanguages.map((Language language) {
            return DropdownMenuItem<Language>(
              value: language,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF3B82F6).withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          _getLanguageFlag(language.code),
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            language.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1E293B),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            language.nativeName,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF64748B),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
          onChanged: (Language? newLanguage) {
            if (newLanguage != null) {
              setState(() {
                _languageService.changeLanguage(newLanguage);
              });
            }
          },
        ),
      ),
    );
  }

  String _getLanguageFlag(String languageCode) {
    switch (languageCode) {
      case 'en':
        return '🇺🇸';
      case 'hi':
        return '🇮🇳';
      case 'mr':
        return '🇮🇳';
      case 'te':
        return '🇮🇳';
      case 'ta':
        return '🇮🇳';
      case 'ml':
        return '🇮🇳';
      default:
        return '🌐';
    }
  }
}