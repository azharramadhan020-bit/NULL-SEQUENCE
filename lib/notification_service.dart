import 'dart:math';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';

class NotificationService {
  static Future<void> initialize() async {
    await AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelKey: 'system_channel',
          channelName: 'System: Sequence',
          channelDescription: 'Distortion Event Alerts',
          defaultColor: Colors.deepPurpleAccent,
          ledColor: Colors.white,
          playSound: false,
          enableVibration: false,
          importance: NotificationImportance.High,
        )
      ],
    );
  }

  static Future<void> scheduleDailyRandom() async {
    DateTime now = DateTime.now();
    // choose morning or afternoon window randomly
    bool morning = Random().nextBool();
    int hour = morning ? (6 + Random().nextInt(7)) : (16 + Random().nextInt(4));
    int minute = Random().nextInt(60);
    final DateTime scheduled = DateTime(now.year, now.month, now.day, hour, minute);

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: Random().nextInt(100000),
        channelKey: 'system_channel',
        title: '[NULL] System: Sequence',
        body: _randomBody(),
        notificationLayout: NotificationLayout.Default,
        playSound: false,
        displayOnForeground: true,
        displayOnBackground: true,
      ),
      schedule: NotificationCalendar(
        hour: scheduled.hour,
        minute: scheduled.minute,
        second: 0,
        repeats: false,
      ),
    );
  }

  static String _randomBody() {
    final List<String> samples = [
      'Distortion detected nearby...',
      'Sequence initializing... check terminal.',
      'A new quest has appeared.',
      'Observe the world for anomalies.',
      'Reality fluctuation increasing...',
      'Access to a secondary directive may be available.'
    ];
    return samples[Random().nextInt(samples.length)];
  }
}
