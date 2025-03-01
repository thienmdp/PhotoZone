import 'package:uuid/uuid.dart';
import '../models/notification_item.dart';
import 'database_service.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final _db = DatabaseService.instance;

  Future<List<NotificationItem>> getNotifications() async {
    final notifications = <NotificationItem>[];

    // Tạo thông báo tổng kết ngày
    final todayStats = await _getTodayStats();
    if (todayStats.visitedPlaces > 0 || todayStats.newPhotos > 0) {
      notifications.add(
        NotificationItem(
          id: const Uuid().v4(),
          title: 'Tổng kết hoạt động hôm nay',
          message: _buildDailySummaryMessage(todayStats),
          time: DateTime.now(),
          type: NotificationType.activitySummary,
        ),
      );
    }

    // Thông báo về ảnh mới
    if (todayStats.newPhotos > 0) {
      notifications.add(
        NotificationItem(
          id: const Uuid().v4(),
          title: 'Ảnh mới',
          message: 'Bạn đã chụp ${todayStats.newPhotos} ảnh mới hôm nay',
          time: DateTime.now(),
          type: NotificationType.newPhotos,
        ),
      );
    }

    // Thông báo về địa điểm đã ghé thăm
    if (todayStats.visitedPlaces > 0) {
      notifications.add(
        NotificationItem(
          id: const Uuid().v4(),
          title: 'Địa điểm đã ghé thăm',
          message:
              'Bạn đã ghé thăm ${todayStats.visitedPlaces} địa điểm hôm nay',
          time: DateTime.now(),
          type: NotificationType.placeVisit,
        ),
      );
    }

    // Thông báo đạt mốc
    final milestones = await _checkMilestones();
    notifications.addAll(milestones);

    return notifications;
  }

  Future<_DailyStats> _getTodayStats() async {
    // TODO: Implement actual stats from database
    return _DailyStats(
      visitedPlaces: 3,
      newPhotos: 12,
      totalPlaces: 15,
      totalPhotos: 150,
    );
  }

  String _buildDailySummaryMessage(_DailyStats stats) {
    final parts = <String>[];

    if (stats.visitedPlaces > 0) {
      parts.add('ghé thăm ${stats.visitedPlaces} địa điểm');
    }

    if (stats.newPhotos > 0) {
      parts.add('chụp ${stats.newPhotos} ảnh mới');
    }

    if (parts.isEmpty) return 'Chưa có hoạt động nào hôm nay';

    return 'Hôm nay bạn đã ${parts.join(', ')}';
  }

  Future<List<NotificationItem>> _checkMilestones() async {
    final milestones = <NotificationItem>[];
    final stats = await _getTodayStats();

    // Check total photos milestone
    if (stats.totalPhotos >= 100) {
      milestones.add(
        NotificationItem(
          id: const Uuid().v4(),
          title: 'Mốc quan trọng!',
          message: 'Chúc mừng! Bạn đã chụp hơn 100 ảnh',
          time: DateTime.now(),
          type: NotificationType.milestone,
        ),
      );
    }

    // Check total places milestone
    if (stats.totalPlaces >= 10) {
      milestones.add(
        NotificationItem(
          id: const Uuid().v4(),
          title: 'Mốc quan trọng!',
          message: 'Bạn đã ghé thăm hơn 10 địa điểm',
          time: DateTime.now(),
          type: NotificationType.milestone,
        ),
      );
    }

    return milestones;
  }
}

class _DailyStats {
  final int visitedPlaces;
  final int newPhotos;
  final int totalPlaces;
  final int totalPhotos;

  _DailyStats({
    required this.visitedPlaces,
    required this.newPhotos,
    required this.totalPlaces,
    required this.totalPhotos,
  });
}
