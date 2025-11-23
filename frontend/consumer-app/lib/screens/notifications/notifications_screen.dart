import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../services/notification_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<dynamic> _notifications = [];
  bool _isLoading = true;
  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.accessToken;

      if (token == null) {
        throw Exception('Not authenticated');
      }

      final notifications = await _notificationService.getNotifications(token);
      setState(() {
        _notifications = notifications;
        _isLoading = false;
      });
    } catch (e) {
      // If API fails, show empty state
      setState(() {
        _notifications = [];
        _isLoading = false;
      });
    }
  }

  Future<void> _markAllAsRead() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.accessToken;

      if (token != null) {
        await _notificationService.markAllAsRead(token);
        _loadNotifications();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (_notifications.isNotEmpty)
            TextButton(
              onPressed: _markAllAsRead,
              child: const Text('Mark all read'),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.notifications_none, size: 80, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      const Text(
                        'No Notifications',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'You\'re all caught up!',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadNotifications,
                  child: ListView.builder(
                    itemCount: _notifications.length,
                    itemBuilder: (context, index) {
                      final notification = _notifications[index];
                      return _buildNotification(
                        notification: notification,
                      );
                    },
                  ),
                ),
    );
  }

  Widget _buildNotification({required Map<String, dynamic> notification}) {
    final title = notification['title'] ?? 'Notification';
    final message = notification['message'] ?? notification['content'] ?? '';
    final createdAt = notification['createdAt'] ?? notification['timestamp'];
    final isRead = notification['isRead'] ?? notification['read'] ?? false;
    final type = notification['notificationType'] ?? notification['type'] ?? 'INFO';

    IconData icon;
    Color iconColor;

    switch (type.toString().toUpperCase()) {
      case 'ORDER':
      case 'PURCHASE':
        icon = Icons.shopping_bag;
        iconColor = Colors.blue;
        break;
      case 'GIFT':
        icon = Icons.card_giftcard;
        iconColor = Colors.pink;
        break;
      case 'REDEMPTION':
        icon = Icons.check_circle;
        iconColor = Colors.green;
        break;
      case 'PROMOTION':
        icon = Icons.local_offer;
        iconColor = Colors.orange;
        break;
      default:
        icon = Icons.info;
        iconColor = Colors.grey;
    }

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
            if (createdAt != null) ...[
              const SizedBox(height: 4),
              Text(
                _formatDate(createdAt),
                style: TextStyle(fontSize: 11, color: Colors.grey[500]),
              ),
            ],
          ],
        ),
        isThreeLine: true,
        onTap: () async {
          if (!isRead) {
            try {
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              final token = authProvider.accessToken;
              if (token != null && notification['id'] != null) {
                await _notificationService.markAsRead(token, notification['id']);
                _loadNotifications();
              }
            } catch (e) {
              // Ignore errors
            }
          }
        },
      ),
    );
  }

  String _formatDate(dynamic dateStr) {
    try {
      final date = DateTime.parse(dateStr.toString());
      return DateFormat('MMM d, h:mm a').format(date);
    } catch (e) {
      return 'Recently';
    }
  }
}
