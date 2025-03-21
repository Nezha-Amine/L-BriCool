import 'package:flutter/material.dart';

class LanguageSelector extends StatefulWidget {
  final List<String> selectedLanguages;
  final Function(List<String>) onLanguagesChanged;

  const LanguageSelector({
    Key? key,
    required this.selectedLanguages,
    required this.onLanguagesChanged,
  }) : super(key: key);

  @override
  _LanguageSelectorState createState() => _LanguageSelectorState();
}

class _LanguageSelectorState extends State<LanguageSelector> {
  final List<String> _availableLanguages = [
    'English',
    'French',
    'Arabic',
    'Spanish',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Required language(s)',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 10),
        Wrap(
          spacing: 8,
          children: _availableLanguages.map((language) {
            final isSelected = widget.selectedLanguages.contains(language);
            return FilterChip(
              label: Text(language),
              selected: isSelected,
              backgroundColor: Colors.white,
              side: BorderSide(color: Colors.grey),
              selectedColor: Color(0xFFE1D9F6),
              onSelected: (selected) {
                final updatedLanguages = List<String>.from(widget.selectedLanguages);
                if (selected) {
                  if (!updatedLanguages.contains(language)) {
                    updatedLanguages.add(language);
                  }
                } else {
                  updatedLanguages.remove(language);
                }
                widget.onLanguagesChanged(updatedLanguages);
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}