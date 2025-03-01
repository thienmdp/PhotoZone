import 'package:flutter/material.dart';

enum NotificationType {
  activitySummary, // Tổng kết hoạt động
  newPhotos, // Chụp ảnh mới
  placeVisit, // Ghé thăm địa điểm
  milestone, // Đạt mốc quan trọng
  system, // Thông báo hệ thống
}

class NotificationItem {
  final String id;
  final String title;
  final String message;
  final DateTime time;
  final NotificationType type;
  final bool isRead;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.time,
    required this.type,
    this.isRead = false,
  });

  IconData get icon {
    switch (type) {
      case NotificationType.activitySummary:
        return Icons.event_note;
      case NotificationType.newPhotos:
        return Icons.photo_camera;
      case NotificationType.placeVisit:
        return Icons.place;
      case NotificationType.milestone:
        return Icons.emoji_events;
      case NotificationType.system:
        return Icons.notifications;
    }
  }

  Color get color {
    switch (type) {
      case NotificationType.activitySummary:
        return Colors.blue;
      case NotificationType.newPhotos:
        return Colors.green;
      case NotificationType.placeVisit:
        return Colors.orange;
      case NotificationType.milestone:
        return Colors.purple;
      case NotificationType.system:
        return Colors.grey;
    }
  }
}
