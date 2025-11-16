import 'package:flutter/material.dart';

class PrivacySettingsScreen extends StatefulWidget {
  const PrivacySettingsScreen({Key? key}) : super(key: key);

  @override
  State<PrivacySettingsScreen> createState() => _PrivacySettingsScreenState();
}

class _PrivacySettingsScreenState extends State<PrivacySettingsScreen> {
  bool _shareLocation = true;
  bool _shareActivity = false;
  bool _allowMarketing = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy & Security'),
      ),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Privacy Settings',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          SwitchListTile(
            title: const Text('Share Location'),
            subtitle: const Text('Help us show nearby merchants'),
            value: _shareLocation,
            onChanged: (value) => setState(() => _shareLocation = value),
          ),
          SwitchListTile(
            title: const Text('Share Activity'),
            subtitle: const Text('Show purchase history to friends'),
            value: _shareActivity,
            onChanged: (value) => setState(() => _shareActivity = value),
          ),
          SwitchListTile(
            title: const Text('Marketing Communications'),
            subtitle: const Text('Receive promotional emails and notifications'),
            value: _allowMarketing,
            onChanged: (value) => setState(() => _allowMarketing = value),
          ),
          const Divider(),
          const ListTile(
            leading: Icon(Icons.privacy_tip),
            title: Text('Privacy Policy'),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
          ),
          const ListTile(
            leading: Icon(Icons.security),
            title: Text('Data & Security'),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
          ),
          const ListTile(
            leading: Icon(Icons.delete_forever),
            title: Text('Delete Account'),
            subtitle: Text('Permanently delete your account'),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
          ),
        ],
      ),
    );
  }
}















