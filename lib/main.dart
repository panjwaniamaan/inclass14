import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';

Future<void> _messageHandler(RemoteMessage message) async {
  print('Background message: ${message.notification?.body}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(_messageHandler);
  runApp(MessagingTutorial());
}

class MessagingTutorial extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Firebase Messaging',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Firebase Messaging'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String? title;

  MyHomePage({Key? key, this.title}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late FirebaseMessaging messaging;
  String? notificationText;

  @override
  void initState() {
    super.initState();

    messaging = FirebaseMessaging.instance;

    messaging.getToken().then((token) {
      print("FCM Token: $token");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("FCM Token printed to console."),
      ));
    });

    messaging.subscribeToTopic("messaging");

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("Message received in foreground");
      print("Title: ${message.notification?.title}");
      print("Body: ${message.notification?.body}");
      print("Data: ${message.data}");

      String type = message.data['type'] ?? 'regular';
      String alertTitle = type == 'important'
          ? "🚨 Important Alert"
          : "📩 Regular Notification";

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(alertTitle),
            content: Text(message.notification?.body ?? 'No message'),
            actions: [
              TextButton(
                child: Text("OK"),
                onPressed: () => Navigator.of(context).pop(),
              )
            ],
          );
        },
      );
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("User tapped on the notification");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? 'FCM Demo'),
      ),
      body: Center(
        child: Text(
          "Waiting for notifications...",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}