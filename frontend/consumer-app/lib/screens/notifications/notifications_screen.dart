import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text('Mark all read'),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: 5, // TODO: Load actual notifications
        itemBuilder: (context, index) {
          return _buildNotification(
            icon: Icons.check_circle,
            iconColor: Colors.green,
            title: 'Purchase Successful',
            message: 'Your voucher for Brown Coffee is ready in your wallet',
            time: DateTime.now().subtract(Duration(hours: index)),
            isRead: index > 2,
          );
        },
      ),
    );
  }

  Widget _buildNotification({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String message,
    required DateTime time,
    required bool isRead,
  }) {
    return Container(
      color: isRead ? Colors.white : Colors.blue[50],
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: iconColor.withOpacity(0.2),
          child: Icon(icon, color: iconColor),
        ),
        title: Text(
          title,
          style: TextStyle(fontWeight: isRead ? FontWeight.normal : FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message),
            const SizedBox(height: 4),
            Text(
              DateFormat('MMM d, h:mm a').format(time),
              style: TextStyle(fontSize: 11, color: Colors.grey[500]),
            ),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }
}















