import 'package:flutter/material.dart';

class NotificationsSettingsScreen extends StatefulWidget {
  const NotificationsSettingsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsSettingsScreen> createState() => _NotificationsSettingsScreenState();
}

class _NotificationsSettingsScreenState extends State<NotificationsSettingsScreen> {
  bool _pushNotifications = true;
  bool _emailNotifications = true;
  bool _smsNotifications = false;
  bool _orderUpdates = true;
  bool _promotionalOffers = true;
  bool _voucherReminders = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Notification Preferences',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          SwitchListTile(
            title: const Text('Push Notifications'),
            subtitle: const Text('Receive push notifications on your device'),
            value: _pushNotifications,
            onChanged: (value) {
              setState(() => _pushNotifications = value);
              _showSaveMessage('Push notifications ${value ? "enabled" : "disabled"}');
            },
          ),
          const Divider(),
          SwitchListTile(
            title: const Text('Email Notifications'),
            subtitle: const Text('Receive notifications via email'),
            value: _emailNotifications,
            onChanged: (value) {
              setState(() => _emailNotifications = value);
              _showSaveMessage('Email notifications ${value ? "enabled" : "disabled"}');
            },
          ),
          const Divider(),
          SwitchListTile(
            title: const Text('SMS Notifications'),
            subtitle: const Text('Receive notifications via SMS'),
            value: _smsNotifications,
            onChanged: (value) {
              setState(() => _smsNotifications = value);
              _showSaveMessage('SMS notifications ${value ? "enabled" : "disabled"}');
            },
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Notification Types',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          SwitchListTile(
            title: const Text('Order Updates'),
            subtitle: const Text('Get notified about your order status'),
            value: _orderUpdates,
            onChanged: (value) {
              setState(() => _orderUpdates = value);
              _showSaveMessage('Order updates ${value ? "enabled" : "disabled"}');
            },
          ),
          const Divider(),
          SwitchListTile(
            title: const Text('Promotional Offers'),
            subtitle: const Text('Receive special offers and discounts'),
            value: _promotionalOffers,
            onChanged: (value) {
              setState(() => _promotionalOffers = value);
              _showSaveMessage('Promotional offers ${value ? "enabled" : "disabled"}');
            },
          ),
          const Divider(),
          SwitchListTile(
            title: const Text('Voucher Reminders'),
            subtitle: const Text('Reminders for unused vouchers'),
            value: _voucherReminders,
            onChanged: (value) {
              setState(() => _voucherReminders = value);
              _showSaveMessage('Voucher reminders ${value ? "enabled" : "disabled"}');
            },
          ),
        ],
      ),
    );
  }

  void _showSaveMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

