import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cms/models/user.dart';
import 'package:cms/screens/Student/widgets/StudentCard.dart';
import 'package:cms/screens/Student/widgets/student_notice.dart';
import 'package:cms/screens/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StudentHomePage extends StatefulWidget {
  const StudentHomePage({super.key});

  @override
  State<StudentHomePage> createState() => _StudentHomePageState();
}

class _StudentHomePageState extends State<StudentHomePage> {
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

  User? user = FirebaseAuth.instance.currentUser;
  StudentModel student = StudentModel();
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  @override
  void initState() {
    super.initState();
    // firebaseMessaging.getToken().then((token) {
    //   saveTokens(token);
    // });
    // FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    //   RemoteNotification? notification = message.notification;
    //   AndroidNotification? android = message.notification?.android;
    //   if (notification != null && android != null) {
    //     flutterLocalNotificationsPlugin.show(
    //       notification.hashCode,
    //       notification.title,
    //       notification.body,
    //       NotificationDetails(),
    //     );
    //   }
    // });
    // FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    //   print('A new onMessageOpenedApp event was published!');
    //   // Navigator.pushNamed(context, '/message',
    //   //     arguments: MessageArguments(message, true));
    // });
    FirebaseFirestore.instance
        .collection('students')
        .doc(user!.uid)
        .get()
        .then((value) {
      student = StudentModel.fromMap(value.data());
      setState(() {});
    });
  }

  // Future<void> saveTokens(var token) async {
  //   try {
  //     await _firestore.collection('tokens').add({
  //       'token': token,
  //     });
  //   } catch (e) {
  //     print(e);
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.grey,
        actions: [
          IconButton(
            onPressed: () {
              logout(context);
            },
            icon: const Icon(Icons.logout),
          )
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              StudentCard(
                student: student,
              ),
              const SizedBox(
                height: 20,
              ),
              const Text(
                "Notice ",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              StudNotice(mybranch: student.branch ?? ""),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> logout(BuildContext context) async {
  await FirebaseAuth.instance.signOut();
  Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginScreen()));
  final prefs = await SharedPreferences.getInstance();
  prefs.setBool('isLoggedIn', false);
}