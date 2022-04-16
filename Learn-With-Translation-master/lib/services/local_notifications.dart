import 'package:flutter_local_notifications/flutter_local_notifications.dart';

FlutterLocalNotificationsPlugin localNotificationsPlugin = FlutterLocalNotificationsPlugin();

void initNotifications () async {
  var initializeAndroid = const AndroidInitializationSettings('@mipmap/ic_launcher');
  var initializeIOS = const IOSInitializationSettings();
  var initializationSettings = InitializationSettings(android: initializeAndroid, iOS: initializeIOS);

  await localNotificationsPlugin.initialize(initializationSettings);
}

Future singleNotification(DateTime scheduledDate, String title, String body, int hashCode, {String? sound}) async {
  var androidChannel = const AndroidNotificationDetails(
    'channel-id', 'channel-name', channelDescription: 'channel-description',
    importance: Importance.max,
    priority: Priority.max,
    playSound: true,
  );

  var iosChannel = const IOSNotificationDetails();
  var platformChannel = NotificationDetails(android: androidChannel, iOS: iosChannel);

  localNotificationsPlugin.schedule(hashCode, title, body, scheduledDate, platformChannel, payload: hashCode.toString());
}