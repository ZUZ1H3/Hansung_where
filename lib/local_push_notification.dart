import 'dart:async';
import 'dart:io';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'main.dart';

class LocalPushNotifications {
  //플러그인 인스턴스 생성
  static final FlutterLocalNotificationsPlugin
  _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  //푸시 알림 스트림 생성
  static final StreamController<String?> notificationStream =
  StreamController<String?>.broadcast();

  //푸시 알림을 탭했을 때 호출되는 콜백 함수
  static void onNotificationTap(NotificationResponse notificationResponse) {
    final payload = notificationResponse.payload;
    if (payload != null) {
      notificationStream.add(payload);
    }
  }

  //플러그인 초기화
  static Future init() async {
    tz.initializeTimeZones(); // 이 부분을 추가하세요

    //Android
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    //ios
    const DarwinInitializationSettings initializationSettingsDarwin =
    DarwinInitializationSettings();
    //Linux
    const LinuxInitializationSettings initializationSettingsLinux =
    LinuxInitializationSettings(defaultActionName: 'Open notification');

    const InitializationSettings initializationSettings =
    InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsDarwin,
        linux: initializationSettingsLinux);

    //안드로이드 푸시 알림 권한 요청
    if(Platform.isAndroid) {
      _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()!
          .requestNotificationsPermission();
    }

    _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse:
      onNotificationTap, //푸시 알림 탭 시 호출되는 콜백 함수 등록
      onDidReceiveBackgroundNotificationResponse:
      onNotificationTap,
    );
  }

  //일반 푸시 알림 보내기
  static Future showSimpleNotification({
    required String title,
    required String body,
    required String payload,
  }) async {
    const AndroidNotificationDetails androidNotificationDetails =
    AndroidNotificationDetails(
        'comment_notifications', // 채널 ID
        '댓글 알림', // 채널 이름
        channelDescription: '게시물에 댓글이 달렸을 때 알림',
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'ticker');
    const NotificationDetails notificationDetails =
    NotificationDetails(android: androidNotificationDetails);
    await _flutterLocalNotificationsPlugin.show(0, title, body, notificationDetails, payload: payload);
  }


  //채널 id에 해당하는 푸시 알림 취소
  static Future cancel(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
  }

  //푸시 알림 전체 취소
  static Future cancelAll() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }
}