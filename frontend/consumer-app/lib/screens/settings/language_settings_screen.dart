import 'package:flutter/material.dart';

class LanguageSettingsScreen extends StatefulWidget {
  const LanguageSettingsScreen({Key? key}) : super(key: key);

  @override
  State<LanguageSettingsScreen> createState() => _LanguageSettingsScreenState();
}

class _LanguageSettingsScreenState extends State<LanguageSettingsScreen> {
  String _selectedLanguage = 'en';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Language'),
      ),
      body: ListView(
        children: [
          _buildLanguageTile('en', '🇬🇧', 'English'),
          _buildLanguageTile('km', '🇰🇭', 'ភាសាខ្មែរ (Khmer)'),
          _buildLanguageTile('zh', '🇨🇳', '中文 (Chinese)'),
          _buildLanguageTile('th', '🇹🇭', 'ไทย (Thai)'),
        ],
      ),
    );
  }

  Widget _buildLanguageTile(String code, String flag, String name) {
    return RadioListTile<String>(
      title: Row(
        children: [
          Text(flag, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Text(name),
        ],
      ),
      value: code,
      groupValue: _selectedLanguage,
      onChanged: (value) {
        setState(() => _selectedLanguage = value!);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Language changed to $name')),
        );
      },
    );
  }
}















