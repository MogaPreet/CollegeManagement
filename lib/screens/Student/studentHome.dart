import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cms/models/user.dart';
import 'package:cms/screens/Student/widgets/StudentCard.dart';
import 'package:cms/screens/Student/widgets/dashboard_data.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cms/screens/Student/widgets/assignemntCard.dart';
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
  int selectedIndex = 0;
  void onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> _pages = <Widget>[
      Home(student: student),
      StudentAssignmentCard(
        student: student,
      ),
    ];
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        backgroundColor: Colors.transparent,
        unselectedItemColor: Colors.grey,
        elevation: 0,
        selectedItemColor: Colors.black,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        onTap: onItemTapped,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.work_rounded),
            label: 'Assignment',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'User',
          ),
        ],
      ),
      appBar: AppBar(
        elevation: 0,
        titleSpacing: 0,
        title: Padding(
            padding:
                EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.05),
            child: Text(
              "Hey, ${student.firstName ?? ""}",
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            )),
        actions: [
          IconButton(
            onPressed: () {
              logout(context);
            },
            icon: const Icon(
              Icons.logout,
              color: Colors.white,
            ),
          )
        ],
      ),
      body: _pages.elementAt(selectedIndex),
    );
  }
}

class Home extends StatelessWidget {
  const Home({
    Key? key,
    required this.student,
  }) : super(key: key);

  final StudentModel student;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Stack(
              children: [
                Container(
                  margin: EdgeInsets.only(
                      left: MediaQuery.of(context).size.width * 0.1),
                  child: SvgPicture.asset(
                    'assets/students_final.svg',
                    width: MediaQuery.of(context).size.width,
                  ),
                ),
                Positioned(
                  left: MediaQuery.of(context).size.width * 0.05,
                  top: MediaQuery.of(context).size.height * 0.10,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Next Class',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 20,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "Thu 16 March, \n11:00 AM",
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 20,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.5,
                        child: Text(
                          'System Programming and Compiler Design',
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            // const Text(
            //   "Notice ",
            //   style: TextStyle(
            //     fontWeight: FontWeight.bold,
            //     fontSize: 20,
            //   ),
            // ),
            // StudNotice(mybranch: student.branch ?? ""),
            Padding(
              padding: EdgeInsets.only(
                  left: MediaQuery.of(context).size.width * 0.05,
                  right: MediaQuery.of(context).size.width * 0.05),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      DashBoardCard(
                        color: Colors.red.shade50,
                        subTitle: "75%",
                        title: "Total Attendance",
                      ),
                      DashBoardCard(
                        color: Colors.blue.shade50,
                        subTitle: "75%",
                        title: "Total Attendance",
                      ),
                    ],
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.015,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      DashBoardCard(
                        color: Colors.purple.shade50,
                        subTitle: "75%",
                        title: "Total Attendance",
                      ),
                      DashBoardCard(
                        color: Colors.pink.shade50,
                        subTitle: "75%",
                        title: "Total Attendance",
                      ),
                    ],
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.020,
                  ),
                  Text(
                    "Notice",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  StudNotice(mybranch: student.branch ?? ""),
                ],
              ),
            )
          ],
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
