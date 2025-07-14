import 'dart:convert';
import 'dart:io';
import 'package:des_mobile_admin_v3/config.dart';
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
  // NotificationService.showNotification(message);
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
    print('[🔔] _updateBadge called with messageData: $messageData');

    final storage = FlutterSecureStorage();
    final valueStorage = await storage.read(key: 'dataUserLoginDES');
    final token = await storage.read(key: 'tokenD');

    print('[📦] Storage email/token: $valueStorage / $token');

    final dataValue =
        valueStorage == null ? {'email': ''} : json.decode(valueStorage);
    final email = dataValue['email']?.toString() ?? '';

    if ((token != null && token != '') && (email != '')) {
      try {
        final response = await Dio().post(
          '$ondeURL/m/v2/notification/count',
          data: {"email": email, "token": token},
        );

        final total = response.data['total'];
        print('[✅] Badge total from API: $total');

        if (total != null && total is int) {
          await FlutterNewBadger.setBadge(total);
          print('[📱] Badge updated to: $total');
        }
      } catch (e) {
        print('[❌] Error updating badge: $e');
      }
    } else {
      print('[⚠️] Missing email/token, badge not updated');
    }
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
      },
    );

    // await flutterLocalNotificationsPlugin.initialize(initializationSettings);
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
        } catch (e) {
          print('------3--->>>  Error registering notification token: $e');
        }
      } else {
        print('------4--->>>  Failed to get FCM token');
      }
    });

    FirebaseMessaging.instance.subscribeToTopic('des-admin');

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      print(
        '------>>>> Message received in foreground: ${message.notification?.title}',
      );
      await _updateBadge(message.data);
      await showNotification(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      print('------>>>> Notification opened!');
      await _updateBadge(message.data);
      
    });
  }
}
