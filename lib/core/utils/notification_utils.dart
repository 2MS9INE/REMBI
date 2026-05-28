import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../../features/notifications/presentation/providers/notification_log_provider.dart';

final _plugin = FlutterLocalNotificationsPlugin();

// ProviderContainer for logging notifications, set in main.dart
ProviderContainer? _container;

void setNotificationContainer(ProviderContainer container) {
  _container = container;
}

Future<void> initNotifications() async {
  tz.initializeTimeZones();

  const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
  const iosSettings = DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );
  const initSettings = InitializationSettings(
    android: androidSettings,
    iOS: iosSettings,
  );

  await _plugin.initialize(initSettings);

  if (Platform.isAndroid) {
    const channel = AndroidNotificationChannel(
      'rembi_channel',
      'Rembi Notifications',
      description: 'Rembi listing and account notifications',
      importance: Importance.high,
    );
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  }
}

/// Schedules a notification 7 days before expiry.
Future<void> scheduleExpiryNotification(
  String listingId,
  String listingTitle,
  DateTime expiresAt,
) async {
  final notifyAt = expiresAt.subtract(const Duration(days: 7));
  if (notifyAt.isBefore(DateTime.now())) return;

  final id = listingId.hashCode.abs() % 100000;

  const androidDetails = AndroidNotificationDetails(
    'rembi_channel',
    'Rembi Notifications',
    importance: Importance.high,
    priority: Priority.high,
  );
  const notifDetails = NotificationDetails(
    android: androidDetails,
    iOS: DarwinNotificationDetails(),
  );

  await _plugin.zonedSchedule(
    id,
    'إعلانك على وشك الانتهاء',
    'إعلان $listingTitle سينتهي خلال 7 أيام. جدد الإعلان للإبقاء عليه ظاهراً.',
    tz.TZDateTime.from(notifyAt, tz.local),
    notifDetails,
    payload: '/farmer/listing/$listingId/edit',
    androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
  );
}

/// Cancels a previously scheduled notification.
Future<void> cancelNotification(String listingId) async {
  final id = listingId.hashCode.abs() % 100000;
  await _plugin.cancel(id);
}

/// Shows an immediate notification and logs it.
Future<void> showImmediateNotification(String title, String body) async {
  const androidDetails = AndroidNotificationDetails(
    'rembi_channel',
    'Rembi Notifications',
    importance: Importance.high,
    priority: Priority.high,
  );
  const notifDetails = NotificationDetails(android: androidDetails);
  final id = DateTime.now().millisecondsSinceEpoch % 100000;
  await _plugin.show(id, title, body, notifDetails);
}
