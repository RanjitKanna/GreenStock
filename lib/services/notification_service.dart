import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<void> initialize() async {
    print('🔔 NotificationService: initialize started');

    try {
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      print(
        '🔔 Notification permission: '
        '${settings.authorizationStatus}',
      );

      print('🔔 Getting FCM token...');

      final token = await _messaging.getToken();

      print('🔥 FCM TOKEN: $token');

      if (token == null) {
        print('❌ FCM token is NULL');
      } else {
        print('✅ FCM token received');
      }
    } catch (e, stackTrace) {
      print('❌ FCM ERROR: $e');
      print('❌ STACK TRACE: $stackTrace');
    }
  }
}
