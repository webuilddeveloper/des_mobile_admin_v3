import 'dart:convert';
import 'dart:io';
import 'package:des_mobile_admin_v3/config.dart';
import 'package:des_mobile_admin_v3/shared/secure_storage.dart';
import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_new_badger/flutter_new_badger.dart';
import 'package:shared_preferences/shared_preferences.dart';

FirebaseOptions firebaseOption = FirebaseOptions(
  apiKey:
      Platform.isAndroid
          ? "AIzaSyAZXtQSv6669nz_kFXK0wDlBqvER3mPYuE"
          : "AIzaSyBnMhHuyDpQcRYHw-eiZnMXbu3Xi9-gL9M",
  appId:
      Platform.isAndroid
          ? "1:795306744403:android:7e4be56a79b18772bd84a6"
          : "1:795306744403:ios:0f1548853b2ec325bd84a6",
  messagingSenderId: "795306744403",
  projectId: "des-admin",
);

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: firebaseOption);

  print('Handling a background message: ${message.messageId}');
  await NotificationService._updateBadge(message.data);
  await NotificationService.showNotification(message);
}

class NotificationService {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  static const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/launcher_icon');

  static const DarwinInitializationSettings initializationSettingsIOS =
      DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

  static const InitializationSettings initializationSettings =
      InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );

  static const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    importance: Importance.high,
  );

  static Future<void> _updateBadge(Map<String, dynamic> messageData) async {
    try {
      var accessToken = await ManageStorage.read('accessToken_122') ?? '';
      final response = await Dio().get(
        '$ondeURL/api/Notify/count/me?isPortal=false',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $accessToken',
          },
        ),
      );

      final total = response.data['data']['notRead'];

      // เพิ่ม debug ข้อมูลจาก API
      print('[📊] Full API Response: ${response.data}');
      print('[🔢] notRead value: $total');
      print('[🔢] notRead type: ${total.runtimeType}');

      int badgeCount = 0;
      if (total != null && total is int) {
        badgeCount = total;
      } else {
        badgeCount = int.tryParse(total.toString()) ?? 0;
      }

      print('[🏷️] Setting badge to: $badgeCount');

      // ลองใช้ condition ตรวจสอบก่อน setBadge
      if (badgeCount > 0) {
        await FlutterNewBadger.setBadge(badgeCount);
        print('[✅] Badge set successfully');
      } else {
        await FlutterNewBadger.removeBadge();
        print('[🧹] Badge removed (count is 0)');
      }
    } catch (e) {
      print('[❌] Error updating badge: $e');
    }
  }

  static Future<void> updateBadgeManually() async {
    print('[🔄] Manually updating badge...');
    await _updateBadge({});
  }

  // เพิ่ม method สำหรับ clear badge
  static Future<void> clearBadge() async {
    print('[🧹] Clearing badge...');
    await FlutterNewBadger.setBadge(0);
  }

  static Future<void> initialize() async {
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        if (response.payload != null) {
          print('notification payload: ${response.payload}');
        }
        // เมื่อ user tap notification ให้ update badge
        await _updateBadge({});
      },
    );

    print('[🔧] NotificationService initialized');
  }

  static Future<void> requestPermission() async {
    NotificationSettings settings = await FirebaseMessaging.instance
        .requestPermission(
          alert: true,
          announcement: false,
          badge: true,
          sound: true,
          carPlay: false,
          criticalAlert: false,
          provisional: false,
        );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User declined or has not accepted permission');
    }

    // หลังจาก request permission แล้ว ให้ update badge
    await _updateBadge({});
  }

  static Future<void> subscribeToAllTopic(param) async {
    await FirebaseMessaging.instance.unsubscribeFromTopic('des-admin');
    await FirebaseMessaging.instance.subscribeToTopic('des-admin');
    print('Subscribed to topic "$param"');
  }

  static Future<void> showNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'high_importance_channel',
          'High Importance Notifications',
          importance: Importance.high,
          priority: Priority.high,
        );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails();

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.show(
      0,
      message.notification?.title,
      message.notification?.body,
      platformChannelSpecifics,
    );
  }

  static void setupFirebaseMessaging() {
    FirebaseMessaging.instance.getToken().then((token) async {
      print('--------->>> FCM Token: $token');
      DateTime now = new DateTime.now();
      var currentYear = now.year;
      var dateStart = '2023-01-01';
      var dateEnd = '$currentYear-12-31';

      if (token != null) {
        try {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          String? accessToken = prefs.getString('access_token');

          final response = await Dio().get(
            '$ondeURL/api/ticket/getTrackTicket/$dateStart/$dateEnd',
            data: {'token': token},
            options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
          );
          await _updateBadge({});
        } catch (e) {
          print('Error registering notification token: $e');
        }
      } else {
        print('Failed to get FCM token');
      }
    });

    FirebaseMessaging.instance.subscribeToTopic('des-admin');
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      await _updateBadge(message.data);
      await showNotification(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      await _updateBadge(message.data);
    });
    FirebaseMessaging.instance.getInitialMessage().then((
      RemoteMessage? message,
    ) async {
      if (message != null) {
        await _updateBadge(message.data);
      }
    });
  }
}
