

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class PushService {
  static Future<void> init() async {
    try {
      final messaging = FirebaseMessaging.instance;

      final settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus !=
              AuthorizationStatus.authorized &&
          settings.authorizationStatus !=
              AuthorizationStatus.provisional) {
        debugPrint('Push dozvola nije odobrena');
        return;
      }

      if (Platform.isIOS) {
        String? apnsToken;

        for (var i = 0; i < 15; i++) {
          apnsToken = await messaging.getAPNSToken();
          if (apnsToken != null) break;

          await Future.delayed(
            const Duration(seconds: 2),
          );
        }

        if (apnsToken == null) {
          debugPrint('APNs token nije dostupan');
          return;
        }

        debugPrint('APNs token je dostupan');
      }

      await messaging
          .setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      final token = await messaging.getToken();
      debugPrint('FCM_TOKEN: $token');

      await messaging.subscribeToTopic(
        'dzemat_updates',
      );

      debugPrint('Pretplacen na dzemat_updates');

      FirebaseMessaging.onMessage.listen((message) {
        debugPrint(
          'Nova notifikacija: ${message.notification?.title}',
        );
      });

      FirebaseMessaging.onMessageOpenedApp.listen(
        (message) {
          debugPrint('Korisnik otvorio notifikaciju');
        },
      );

      final initialMessage =
          await messaging.getInitialMessage();

      if (initialMessage != null) {
        debugPrint('Aplikacija otvorena putem push poruke');
      }
    } catch (e) {
      debugPrint('Push greska: $e');
    }
  }
}
