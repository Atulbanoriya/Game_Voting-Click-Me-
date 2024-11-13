import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:voter_multi_app/features/login/login_view.dart';
import 'package:voter_multi_app/features/notification_view/notification_view.dart';
import 'package:voter_multi_app/features/onboard/onboardingview.dart';
import 'package:voter_multi_app/features/profile/profileviewtab.dart';
import 'custom/notification_helper/notification_helper.dart';
import 'features/dashboard/dashboard.dart';
import 'features/splash/splash.dart';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalStorageService {
  Future<void> saveToken(String token) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  Future<String?> getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> saveData(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  Future<String?> getData(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }
}

// Background message handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
}


final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();


  await Firebase.initializeApp();

  const AndroidInitializationSettings initializationSettingsAndroid =
  AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initializationSettings =
  InitializationSettings(android: initializationSettingsAndroid);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);


  FirebaseMessaging messaging = FirebaseMessaging.instance;
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
    provisional: false,
  );

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    print('User granted permission');
  } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
    print('User granted provisional permission');
  } else {
    print('User declined or has not accepted permission');
  }


  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);


  String? token = await FirebaseMessaging.instance.getToken();
  print("Firebase Token: $token");

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late IO.Socket socket;
  Map<String, dynamic>? _profileData;
  String? _userId;
  String? _phoneMember;
  List<Map<String, dynamic>> messages = [];

  List<Map<String, String?>> notifications = [];

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();


  @override
  void initState() {
    super.initState();
    _initSocket();
    _initializeFCM();
  }

  Future<String?> getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  void _initializeFCM() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Received a foreground message: ${message.messageId}');
      if (message.notification != null) {
        print('Notification Title: ${message.notification!.title}');
        print('Notification Body: ${message.notification!.body}');


        setState(() {
          NotificationService.addNotification(message);
        });

        _showNotification(message.notification!.title, message.notification!.body);
      }
    });


    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Notification clicked with message: ${message.messageId}');
      // Navigate to the NotificationView when the notification is tapped
      navigatorKey.currentState?.push(MaterialPageRoute(builder: (_)=> const NotificationView()));
    });
  }



  Future<void> _showNotification(String? title, String? body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'your_channel_id',
      'your_channel_name',
      channelDescription: 'your_channel_description',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );
    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
    );
  }

  void _initSocket() {
    socket = IO.io('http://190.92.175.165:3000', <String, dynamic>{
      'transports': ['websocket'],
    });

    socket.on('connect', (_) {
      print('Connected to socket');
      if (_phoneMember != null) {
        socket.emit('join', _phoneMember);
      } else {
        print('phone_member is null. Cannot emit join event.');
      }
    });

    socket.on('receiveMessage', (data) {
      setState(() {
        messages.add({
          'text': data['text'],
          'sender': data['sender'],
        });
      });
    });

    socket.on('disconnect', (_) => print('Disconnected from socket'));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
      ),
      navigatorKey: navigatorKey,
      home: const SplashView(),
      routes: {
        '/login': (context) => const LoginView(),
        '/dashboard': (context) => const DashBoardView(token: ""),
        '/onboarding': (context) => const Onboarding(),
        '/profile': (context) => const ProfileView(),
        '/notifications': (context) => const NotificationView(),
      },
    );
  }
}