import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'firebase_options.dart';
import 'screens/main_navigation.dart';

// Firebase background notifications (must be a top-level function).
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  debugPrint('Background push: ${message.notification?.title}');
  debugPrint('Gallery tag: ${message.data['galleryTag']}');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // Foreground messages: iOS displays banners using the presentation settings below.
  // Android needs a local-notifications implementation for foreground banners.
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    debugPrint('PUSH: ${message.notification?.title}');
    debugPrint('TEXT: ${message.notification?.body}');
    debugPrint('GALLERY: ${message.data['galleryTag']}');
  });

  // Currently logs tapped notifications. Opening a specific album requires
  // a navigation method from screens/main_navigation.dart.
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    debugPrint('Notification opened: ${message.data['galleryTag']}');
  });

  runApp(const CloudinaryGalleryApp());

  // Keep app launch responsive while registering for notifications.
  unawaited(initializePushNotifications());

  // Handle a notification that launched a terminated app (without navigation yet).
  unawaited(logInitialNotification());
}

Future<void> logInitialNotification() async {
  try {
    final message = await FirebaseMessaging.instance.getInitialMessage();
    if (message != null) {
      debugPrint('Initial notification gallery: ${message.data['galleryTag']}');
    }
  } catch (error) {
    debugPrint('Initial notification read error: $error');
  }
}

// ---------------------------------------------------
// FIREBASE PUSH NOTIFICATIONS
// ---------------------------------------------------
Future<void> initializePushNotifications() async {
  try {
    final messaging = FirebaseMessaging.instance;

    final settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    debugPrint('Notification permission: ${settings.authorizationStatus}');

    if (Platform.isIOS) {
      await messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      // Wait for APNs before calling FCM APIs on iPhone.
      String? apnsToken = await messaging.getAPNSToken();
      for (int attempt = 1; attempt <= 15 && apnsToken == null; attempt++) {
        debugPrint('Waiting for APNs token: $attempt/15');
        await Future.delayed(const Duration(seconds: 2));
        apnsToken = await messaging.getAPNSToken();
      }

      if (apnsToken == null) {
        debugPrint('APNs token unavailable; topic subscription not completed.');
        return;
      }
      debugPrint('APNs token received.');
    }

    // Keep the existing Firebase topic for earlier/manual updates.
    await messaging.subscribeToTopic('dzemat_updates');
    debugPrint('Subscribed to topic: dzemat_updates');

    // The Cloudflare Worker sends new-gallery notifications to this topic.
    await messaging.subscribeToTopic('dzemat_galerije');
    debugPrint('Subscribed to topic: dzemat_galerije');

    final fcmToken = await messaging.getToken();
    debugPrint(
      fcmToken == null ? 'FCM token unavailable.' : 'FCM token available.',
    );
      debugPrint('FCM TEST TOKEN: $fcmToken');
  } catch (error) {
    debugPrint('Firebase push initialization error: $error');
  }
}

// ---------------------------------------------------
// MAIN APPLICATION
// ---------------------------------------------------
class CloudinaryGalleryApp extends StatelessWidget {
  const CloudinaryGalleryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Dzemat Bochum',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const MainNavigation(),
    );
  }
}
