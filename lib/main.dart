import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint("Background message: ${message.notification?.title}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Push Notification Demo",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.deepPurple,
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  String token = "Loading...";
  String lastNotification = "No notification received";

  @override
  void initState() {
    super.initState();
    initFCM();
  }

  Future<void> initFCM() async {

    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // Request permission
    await messaging.requestPermission();

    // Get device token
    String? deviceToken = await messaging.getToken();

    setState(() {
      token = deviceToken ?? "Token unavailable";
    });

    debugPrint("FCM TOKEN: $token");

    // Foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {

      setState(() {
        lastNotification =
            "${message.notification?.title}\n${message.notification?.body}";
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message.notification?.title ?? "New Notification"),
        ),
      );
    });

    // Notification opened
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint("Notification clicked");
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Firebase Push Notification"),
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const Text(
              "Device Token",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(10),
              ),
              child: SelectableText(token),
            ),

            const SizedBox(height: 30),

            const Text(
              "Last Notification",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                lastNotification,
                style: const TextStyle(fontSize: 16),
              ),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {

                  String? newToken =
                      await FirebaseMessaging.instance.getToken();

                  setState(() {
                    token = newToken ?? "Token unavailable";
                  });

                },
                child: const Text("Refresh Token"),
              ),
            )
          ],
        ),
      ),
    );
  }
}