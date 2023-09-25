import 'package:flutter/material.dart';
import 'package:iso/services/local_notification_service.dart';
import 'package:iso/services/route_generator.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class Data with ChangeNotifier {
  String? token;
  String? fcmToken;
  int? totalFunding;
  int? totalFundingAmount;
  int? totalRevenue;
  String? userName;
  List<String> folderName = [];
  List<String> title = [];
  List<String> file = [];
  List<String> actualFile = [];
  List<int> monthToPassNewUpload = [];
  String profileType = "Select type";
  String uploadProfileType = "";

  String dealId = "";
  DateTime? dealCreated;
  String dealCompanyName = "";
  String dealNumber = "";
  String dealOpportunityStatus = "";
  DateTime? sendToCrmDate;
  DateTime? offerSendDate;
  DateTime? contractInDate;
  DateTime? contractOutDate;
  DateTime? fundedDate;
  String dealStatus = "";

  String profileTitle = "";

  bool profileScreen = false;
  bool homeScreen = true;
  bool notificationScreen = false;

  String offerUrl = "";
  String isoFormUrl = "";
  String w9FormUrl = "";

  int pageNumber = 1;
  String viewDocUrl = "";
}

Future<void> backgroundHandler(RemoteMessage message) async {
  print(message.data.toString());
  print(message.notification?.title);
  LocalNotificationService.display(message);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // LocalNotificationService.initialize();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(backgroundHandler);
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    FirebaseMessaging.instance.requestPermission();
    FirebaseMessaging.instance.getInitialMessage();

    FirebaseMessaging.onMessage.listen((messages) {
      if (messages.notification != null) {
        print(messages.notification?.body);
        print(messages.notification?.title);
      }
      LocalNotificationService.display(messages);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      final routeFromMessage = message.data["route"];
      print(routeFromMessage);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => Data(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        onGenerateRoute: RouteGenerator.generateRoute,
      ),
    );
  }
}
