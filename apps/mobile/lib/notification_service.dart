import 'package:flutter/material.dart';
import 'notifications_screen.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final List<NotificationItem> _notifications = [];
  final ValueNotifier<int> unreadCountNotifier = ValueNotifier<int>(0);

  List<NotificationItem> get notifications => List.unmodifiable(_notifications);
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  void addNotification(NotificationItem notification) {
    _notifications.insert(0, notification);
    _updateUnreadCount();
  }

  void markAsRead(String notificationId) {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = NotificationItem(
        id: _notifications[index].id,
        title: _notifications[index].title,
        message: _notifications[index].message,
        type: _notifications[index].type,
        timestamp: _notifications[index].timestamp,
        isRead: true,
        reportId: _notifications[index].reportId,
      );
      _updateUnreadCount();
    }
  }

  void markAllAsRead() {
    for (int i = 0; i < _notifications.length; i++) {
      if (!_notifications[i].isRead) {
        _notifications[i] = NotificationItem(
          id: _notifications[i].id,
          title: _notifications[i].title,
          message: _notifications[i].message,
          type: _notifications[i].type,
          timestamp: _notifications[i].timestamp,
          isRead: true,
          reportId: _notifications[i].reportId,
        );
      }
    }
    _updateUnreadCount();
  }

  void clearAllNotifications() {
    _notifications.clear();
    _updateUnreadCount();
  }

  void _updateUnreadCount() {
    unreadCountNotifier.value = unreadCount;
  }

  // Methods to add specific notification types
  void addReportSubmittedNotification(String reportId, String category) {
    final notification = NotificationItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'Report Submitted Successfully',
      message: 'Your $category report has been submitted and assigned ID: $reportId',
      type: NotificationType.reportSubmitted,
      timestamp: DateTime.now(),
      reportId: reportId,
    );
    addNotification(notification);
  }

  void addReportUnderReviewNotification(String reportId, String category) {
    final notification = NotificationItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'Report Under Review',
      message: 'Your $category report is now under review by local authorities',
      type: NotificationType.reportUnderReview,
      timestamp: DateTime.now(),
      reportId: reportId,
    );
    addNotification(notification);
  }

  void addReportInProgressNotification(String reportId, String category) {
    final notification = NotificationItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'Report In Progress',
      message: 'Work has started on your $category request',
      type: NotificationType.reportInProgress,
      timestamp: DateTime.now(),
      reportId: reportId,
    );
    addNotification(notification);
  }

  void addReportResolvedNotification(String reportId, String category) {
    final notification = NotificationItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'Report Resolved',
      message: 'Your $category complaint has been resolved. Thank you for reporting!',
      type: NotificationType.reportResolved,
      timestamp: DateTime.now(),
      reportId: reportId,
    );
    addNotification(notification);
  }

  void addReportRejectedNotification(String reportId, String category, String reason) {
    final notification = NotificationItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'Report Rejected',
      message: 'Your $category report ($reportId) was rejected. Reason: $reason',
      type: NotificationType.reportRejected,
      timestamp: DateTime.now(),
      reportId: reportId,
    );
    addNotification(notification);
  }

  void addSystemNotification(String title, String message) {
    final notification = NotificationItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      message: message,
      type: NotificationType.system,
      timestamp: DateTime.now(),
    );
    addNotification(notification);
  }

  // Simulate report status changes for demo purposes
  void simulateReportStatusChanges(String reportId, String category) {
    // Immediately submit
    addReportSubmittedNotification(reportId, category);
    
    // After 5 seconds, under review
    Future.delayed(const Duration(seconds: 5), () {
      addReportUnderReviewNotification(reportId, category);
    });
    
    // After 15 seconds, in progress
    Future.delayed(const Duration(seconds: 15), () {
      addReportInProgressNotification(reportId, category);
    });
    
    // After 30 seconds, resolved (for demo)
    Future.delayed(const Duration(seconds: 30), () {
      addReportResolvedNotification(reportId, category);
    });
  }

  // Initialize with some demo notifications
  void initializeDemoNotifications() {
    final demoNotifications = [
      NotificationItem(
        id: '1',
        title: 'Report Submitted Successfully',
        message: 'Your road damage report has been submitted and assigned ID: RD001',
        type: NotificationType.reportSubmitted,
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        reportId: 'RD001',
      ),
      NotificationItem(
        id: '2',
        title: 'Report Under Review',
        message: 'Your water supply issue report is now under review by local authorities',
        type: NotificationType.reportUnderReview,
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        reportId: 'WS002',
      ),
      NotificationItem(
        id: '3',
        title: 'Report In Progress',
        message: 'Work has started on your street light repair request',
        type: NotificationType.reportInProgress,
        timestamp: DateTime.now().subtract(const Duration(hours: 6)),
        reportId: 'SL003',
      ),
      NotificationItem(
        id: '4',
        title: 'Report Resolved',
        message: 'Your garbage collection complaint has been resolved. Thank you for reporting!',
        type: NotificationType.reportResolved,
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        reportId: 'GC004',
        isRead: true,
      ),
      NotificationItem(
        id: '5',
        title: 'System Maintenance',
        message: 'Scheduled maintenance will occur tomorrow from 2:00 AM - 4:00 AM',
        type: NotificationType.system,
        timestamp: DateTime.now().subtract(const Duration(days: 2)),
        isRead: true,
      ),
    ];

    _notifications.addAll(demoNotifications);
    _updateUnreadCount();
  }
}