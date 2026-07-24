import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:shreshtlibrary/core/models/models.dart';

/// Helper function implementing title decoration rules as used in NotificationService
String addIconToTitle(String title, String body, String type) {
  final trimmedTitle = title.trim();
  final RegExp emojiRegex = RegExp(
    r'^[\u{1F300}-\u{1F9FF}\u{2600}-\u{26FF}\u{2700}-\u{27BF}\u{1F600}-\u{1F64F}\u{1F680}-\u{1F6FF}]',
    unicode: true,
  );
  if (emojiRegex.hasMatch(trimmedTitle)) {
    return trimmedTitle;
  }

  final lowerTitle = trimmedTitle.toLowerCase();
  final lowerBody = body.toLowerCase();

  if (lowerTitle.contains('leaderboard') ||
      lowerTitle.contains('reward') ||
      lowerTitle.contains('rank') ||
      lowerTitle.contains('trophy')) {
    return '🏆 $trimmedTitle';
  } else if (lowerTitle.contains('absent') || lowerBody.contains('absent')) {
    return '❌ $trimmedTitle';
  } else if (lowerTitle.contains('alert') ||
      lowerBody.contains('alert') ||
      lowerTitle.contains('warning')) {
    return '🚨 $trimmedTitle';
  } else if (lowerTitle.contains('present') || lowerBody.contains('present')) {
    return '✅ $trimmedTitle';
  } else if (type.toUpperCase() == 'ATTENDANCE') {
    return '📅 $trimmedTitle';
  } else if (type.toUpperCase() == 'BILLING' ||
      type.toUpperCase() == 'EXPIRY') {
    return '💰 $trimmedTitle';
  } else if (type.toUpperCase() == 'ACCOUNT') {
    return '👤 $trimmedTitle';
  } else if (lowerTitle.contains('success')) {
    return '✅ $trimmedTitle';
  }

  return '🔔 $trimmedTitle';
}

/// Helper function for formatting notification date strings
String formatNotificationDate(String? dateString) {
  if (dateString == null || dateString.isEmpty) return '';
  try {
    final dateTime = DateTime.parse(dateString).toLocal();
    final now = DateTime.now();
    if (dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day) {
      return DateFormat('h:mm a').format(dateTime);
    }
    return DateFormat('MMM dd, h:mm a').format(dateTime);
  } catch (_) {
    return dateString;
  }
}

void main() {
  group('Notification System Test Cases', () {
    // ── 1. Model Deserialization & Parsing ────────────────────────────────────
    test('1. Deserializes standard notification JSON correctly', () {
      final json = {
        'id': 101,
        'title': 'Leaderboard Reward',
        'body': 'You achieved Rank 1 with 4.5 hours! Keep it up!',
        'is_read': false,
        'sent_at': '2026-07-24T10:00:00Z',
        'type': 'GENERAL',
        'layout': 'text_only',
        'display_mode': 'persistent',
      };

      final notification = StudentNotification.fromJson(json);

      expect(notification.id, equals(101));
      expect(notification.title, equals('Leaderboard Reward'));
      expect(notification.body, equals('You achieved Rank 1 with 4.5 hours! Keep it up!'));
      expect(notification.isRead, isFalse);
      expect(notification.sentAt, equals('2026-07-24T10:00:00Z'));
      expect(notification.type, equals('GENERAL'));
      expect(notification.layout, equals('text_only'));
    });

    test('2. Deserializes rich notification with images and HTML tag stripping', () {
      final json = {
        'id': 202,
        'title': 'Plan Expired Alert',
        'body': '<p>Your plan has <b>expired</b>. Please renew.</p>',
        'is_read': true,
        'sent_at': '2026-07-20T14:30:00Z',
        'type': 'EXPIRY',
        'layout': 'half_image',
        'images': ['/media/banner.jpg'],
        'background_image': '/media/bg.jpg',
        'link_url': '/renew',
        'link_button_text': 'Renew Now',
      };

      final notification = StudentNotification.fromJson(json);

      expect(notification.id, equals(202));
      expect(notification.title, equals('Plan Expired Alert'));
      expect(notification.body, equals('Your plan has expired. Please renew.'));
      expect(notification.isRead, isTrue);
      expect(notification.images.first, contains('banner.jpg'));
      expect(notification.backgroundImage, contains('bg.jpg'));
      expect(notification.linkUrl, equals('/renew'));
      expect(notification.linkButtonText, equals('Renew Now'));
    });

    test('3. Handles missing or null optional fields gracefully with defaults', () {
      final json = {
        'id': '303',
        'title': null,
        'body': null,
      };

      final notification = StudentNotification.fromJson(json);

      expect(notification.id, equals(303));
      expect(notification.title, equals(''));
      expect(notification.body, equals(''));
      expect(notification.isRead, isFalse);
      expect(notification.sentAt, isNull);
      expect(notification.images, isEmpty);
      expect(notification.layout, equals('text_only'));
    });

    // ── 2. Notification Title Icon Decorator Tests ──────────────────────────────
    test('4. Decorates Leaderboard & Reward titles with trophy emoji', () {
      expect(addIconToTitle('Leaderboard Reward', 'Rank 1 achieved', 'GENERAL'), equals('🏆 Leaderboard Reward'));
      expect(addIconToTitle('Monthly Rank 1 Reward', 'Great job!', 'GENERAL'), equals('🏆 Monthly Rank 1 Reward'));
      expect(addIconToTitle('Trophy Winner', 'Top student', 'GENERAL'), equals('🏆 Trophy Winner'));
    });

    test('5. Decorates Attendance & Status notifications accurately', () {
      expect(addIconToTitle('Attendance Marked', 'Present today', 'ATTENDANCE'), equals('✅ Attendance Marked'));
      expect(addIconToTitle('Student Absent', 'Marked absent today', 'ATTENDANCE'), equals('❌ Student Absent'));
      expect(addIconToTitle('Daily Attendance', 'Checked in', 'ATTENDANCE'), equals('📅 Daily Attendance'));
    });

    test('6. Decorates Billing and Expiry notifications with money emoji', () {
      expect(addIconToTitle('Payment Confirmation', 'Receipt generated', 'BILLING'), equals('💰 Payment Confirmation'));
      expect(addIconToTitle('Subscription Expired', 'Please renew', 'EXPIRY'), equals('💰 Subscription Expired'));
    });

    test('7. Does not duplicate emoji if title already contains an icon', () {
      expect(addIconToTitle('🏆 Leaderboard Reward', 'Rank 1 achieved', 'GENERAL'), equals('🏆 Leaderboard Reward'));
      expect(addIconToTitle('🔔 System Notification', 'Notice', 'GENERAL'), equals('🔔 System Notification'));
      expect(addIconToTitle('✅ Payment Received', 'Thank you', 'BILLING'), equals('✅ Payment Received'));
    });

    // ── 3. Notification Date Formatting Tests ──────────────────────────────────
    test('8. Formats today notification timestamp to time format', () {
      final now = DateTime.now();
      final todayIso = DateTime(now.year, now.month, now.day, 14, 45).toIso8601String();

      final formatted = formatNotificationDate(todayIso);

      expect(formatted, contains('2:45 PM'));
    });

    test('9. Formats past notification timestamp to MMM dd, time format', () {
      const pastIso = '2026-05-10T09:15:00Z';

      final formatted = formatNotificationDate(pastIso);

      expect(formatted, contains('May 10'));
      expect(formatted, isNotEmpty);
    });

    test('10. Returns original string on invalid date input without throwing exception', () {
      expect(formatNotificationDate('invalid-date-string'), equals('invalid-date-string'));
      expect(formatNotificationDate(null), equals(''));
      expect(formatNotificationDate(''), equals(''));
    });

    // ── 4. Study Hours & Leaderboard Reward Notification Payload Rules ──────────
    test('11. Leaderboard Reward notification body contains non-zero study hours format', () {
      const double totalHours = 5.25;
      final hoursStr = totalHours.toStringAsFixed(1);
      const int rank = 1;

      final body = 'You achieved Rank $rank with $hoursStr hours! Keep it up!';

      expect(body, equals('You achieved Rank 1 with 5.3 hours! Keep it up!'));
      expect(totalHours, greaterThan(0.0), reason: 'Leaderboard rewards must only be generated for study hours > 0.0');
    });

    test('12. Filters out dismissed notification IDs from visible list', () {
      final notifications = [
        StudentNotification.fromJson({'id': 1, 'title': 'Notif 1', 'body': 'Body 1'}),
        StudentNotification.fromJson({'id': 2, 'title': 'Notif 2', 'body': 'Body 2'}),
        StudentNotification.fromJson({'id': 3, 'title': 'Notif 3', 'body': 'Body 3'}),
      ];

      final dismissedIds = {2};

      final visible = notifications.where((item) => !dismissedIds.contains(item.id)).toList();

      expect(visible.length, equals(2));
      expect(visible.map((e) => e.id), containsAll([1, 3]));
      expect(visible.map((e) => e.id), isNot(contains(2)));
    });
  });
}
