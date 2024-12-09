import 'package:strive_project/widget_tree.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/index.dart';
//import 'package:timezone/data/latest.dart';


import 'package:onesignal_flutter/onesignal_flutter.dart';

import 'package:strive_project/services/index.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

 // FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  // OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
  // OneSignal.initialize("e8e1b7c8-a98d-47da-b27d-74ceea4fec8d");
  // OneSignal.Notifications.requestPermission(true);
  OneSignal.initialize("e8e1b7c8-a98d-47da-b27d-74ceea4fec8d");
  //OneSignal.shared.setAppId('YOUR_ONESIGNAL_APP_ID');

  await NotificationService.initialize();
  WidgetsFlutterBinding.ensureInitialized();
  //NotificationService().initNotification();

  runApp(    
    ChangeNotifierProvider(
      create: (context) => ThemeService(), // light theme default
      child: MyApp(),
    ),

  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    return Consumer<ThemeService>(
      builder: (context, themeService, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: themeService.getTheme,
          home: WidgetTree(), // Your main screen
        );
      },
    );
  }
}
