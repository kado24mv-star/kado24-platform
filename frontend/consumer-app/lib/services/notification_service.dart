import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';

class NotificationService {
  // Get user notifications
  Future<List<dynamic>> getNotifications(String token, {int page = 0, int size = 20}) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.apiGatewayUrl}/api/v1/notifications?page=$page&size=$size'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true && data['data'] != null) {
        return data['data']['content'] as List;
      }
    }
    return [];
  }

  // Mark notification as read
  Future<void> markAsRead(String token, int notificationId) async {
    await http.put(
      Uri.parse('${ApiConfig.apiGatewayUrl}/api/v1/notifications/$notificationId/read'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
  }

  // Mark all as read
  Future<void> markAllAsRead(String token) async {
    await http.put(
      Uri.parse('${ApiConfig.apiGatewayUrl}/api/v1/notifications/read-all'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
  }
}

