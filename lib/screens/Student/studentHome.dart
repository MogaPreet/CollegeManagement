import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cms/models/user.dart';
import 'package:cms/screens/Student/widgets/StudentCard.dart';
import 'package:cms/screens/Student/widgets/dashboard_data.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cms/screens/Student/widgets/assignemntCard.dart';
import 'package:cms/screens/Student/widgets/student_notice.dart';
import 'package:cms/screens/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

import '../../main.dart';

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

  String showAppBarText(int currentIndex) {
    switch (currentIndex) {
      case 0:
        return "Hey, ${student.firstName ?? ""}";
      case 1:
        return "Assignment";
      case 2:
        return "Profile";
      default:
        return "Home";
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> _pages = <Widget>[
      Home(student: student),
      StudentAssignmentCard(
        student: student,
      ),
      StudentCard(student: student),
    ];
    return Scaffold(
      bottomSheet: selectedIndex == 2
          ? Container(
              height: MediaQuery.of(context).size.height * 0.4,
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 24,
                  right: 24,
                  top: 24,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Dark Mode',
                        ),
                        Consumer(builder: (context, ref, child) {
                          final theme = ref.watch(themeModeProvider);
                          return IconButton(
                              onPressed: () {
                                ref.read(themeModeProvider.notifier).state =
                                    theme == ThemeMode.light
                                        ? ThemeMode.dark
                                        : ThemeMode.light;
                              },
                              icon: Icon(theme == ThemeMode.dark
                                  ? Icons.light_mode
                                  : Icons.dark_mode));
                        })
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Notification',
                        ),
                        SizedBox(
                          height: 14,
                          child: Switch(
                            value: false,
                            onChanged: (value) {},
                          ),
                        )
                      ],
                    ),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Privacy Policy',
                        ),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                        ),
                      ],
                    ),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'About Us',
                        ),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                        ),
                      ],
                    ),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Faqs',
                        ),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Logout',
                        ),
                        IconButton(
                          padding: const EdgeInsets.all(2),
                          style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                              backgroundColor: Colors.red.shade50),
                          onPressed: () {
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    insetPadding: EdgeInsets.zero,
                                    title: const Text('Logout'),
                                    content: const Text(
                                        'Are you sure you want to logout?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text('No'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          logout(context);
                                        },
                                        child: const Text('Yes'),
                                      ),
                                    ],
                                  );
                                });
                          },
                          icon: const Icon(
                            Icons.logout,
                            size: 14,
                          ),
                        ),
                      ],
                    ),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Version',
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Text(
                          '1.5.5',
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 5,
                    )
                  ],
                ),
              ))
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        backgroundColor: Colors.transparent,
        elevation: 0,
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
                EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.06),
            child: Text(
              showAppBarText(selectedIndex),
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 20,
              ),
            )),
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

  int showUpcomingRange() {
    DateTime now = DateTime.now();
    DateTime range1Start = DateTime(now.year, now.month, now.day, 8, 30);
    DateTime range1End = DateTime(now.year, now.month, now.day, 9, 30);

    DateTime range2Start = DateTime(now.year, now.month, now.day, 9, 30);
    DateTime range2End = DateTime(now.year, now.month, now.day, 10, 30);

    DateTime range3Start = DateTime(now.year, now.month, now.day, 10, 30);
    DateTime range3End = DateTime(now.year, now.month, now.day, 11, 30);

    DateTime range4Start = DateTime(now.year, now.month, now.day, 11, 30);
    DateTime range4End = DateTime(now.year, now.month, now.day, 12, 30);

    DateTime range5Start = DateTime(now.year, now.month, now.day, 12, 30);
    DateTime range5End = DateTime(now.year, now.month, now.day, 13, 30);

    DateTime range6Start = DateTime(now.year, now.month, now.day, 13, 30);
    DateTime range6End = DateTime(now.year, now.month, now.day, 14, 30);

    DateTime range7Start = DateTime(now.year, now.month, now.day, 14, 30);
    DateTime range7End = DateTime(now.year, now.month, now.day, 15, 30);

    DateTime range8Start = DateTime(now.year, now.month, now.day, 15, 30);
    DateTime range8End = DateTime(now.year, now.month, now.day, 16, 30);

    if (now.isAfter(range1Start) && now.isBefore(range1End)) {
      return 2; // Next range is range 2
    } else if (now.isAfter(range2Start) && now.isBefore(range2End)) {
      return 3; // Next range is range 3
    } else if (now.isAfter(range3Start) && now.isBefore(range3End)) {
      return 4; // Next range is range 4
    } else if (now.isAfter(range4Start) && now.isBefore(range4End)) {
      return 5; // Next range is range 5
    } else if (now.isAfter(range5Start) && now.isBefore(range5End)) {
      return 6; // Next range is range 6
    } else if (now.isAfter(range6Start) && now.isBefore(range6End)) {
      return 7; // Next range is range 7
    } else if (now.isAfter(range7Start) && now.isBefore(range7End)) {
      return 8; // Next range is range 8
    } else if (now.isAfter(range8Start) && now.isBefore(range8End)) {
      return 1; // Next range is range 1
    } else {
      return 0; // Default to range 1
    }
  }

  int checkTimeRange() {
    // Get the current time
    DateTime now = DateTime.now();

    // Define the start and end of your time ranges
    // Note: DateTime.month, DateTime.day aren't really used here, so you can set them to any valid value
    DateTime range1Start = DateTime(now.year, now.month, now.day, 8, 30);
    DateTime range1End = DateTime(now.year, now.month, now.day, 9, 30);

    DateTime range2Start = DateTime(now.year, now.month, now.day, 9, 30);
    DateTime range2End = DateTime(now.year, now.month, now.day, 10, 30);

    DateTime range3Start = DateTime(now.year, now.month, now.day, 10, 30);
    DateTime range3End = DateTime(now.year, now.month, now.day, 11, 30);

    DateTime range4Start = DateTime(now.year, now.month, now.day, 11, 30);
    DateTime range4End = DateTime(now.year, now.month, now.day, 12, 30);

    DateTime range5Start = DateTime(now.year, now.month, now.day, 12, 30);
    DateTime range5End = DateTime(now.year, now.month, now.day, 13, 30);

    DateTime range6Start = DateTime(now.year, now.month, now.day, 13, 30);
    DateTime range6End = DateTime(now.year, now.month, now.day, 14, 30);

    DateTime range7Start = DateTime(now.year, now.month, now.day, 14, 30);
    DateTime range7End = DateTime(now.year, now.month, now.day, 15, 30);

    DateTime range8Start = DateTime(now.year, now.month, now.day, 15, 30);
    DateTime range8End = DateTime(now.year, now.month, now.day, 16, 30);

    if (now.isAfter(range1Start) && now.isBefore(range1End)) {
      return 1;
    } else if (now.isAfter(range2Start) && now.isBefore(range2End)) {
      return 2;
    } else if (now.isAfter(range3Start) && now.isBefore(range3End)) {
      return 3;
    } else if (now.isAfter(range4Start) && now.isBefore(range4End)) {
      return 4;
    } else if (now.isAfter(range5Start) && now.isBefore(range5End)) {
      return 5;
    } else if (now.isAfter(range6Start) && now.isBefore(range6End)) {
      return 6;
    } else if (now.isAfter(range7Start) && now.isBefore(range7End)) {
      return 7;
    } else if (now.isAfter(range8Start) && now.isBefore(range8End)) {
      return 8;
    } else {
      return 0;
    }
  }

  String getCurrentDay() {
    DateTime now = DateTime.now();

    List<String> daysOfWeek = [
      "Sunday",
      "Monday",
      "Tuesday",
      "Wednesday",
      "Thursday",
      "Friday",
      "Saturday"
    ];

    int dayIndex = now.weekday;
    return daysOfWeek[dayIndex];
  }

  String getCurrentMonth() {
    // Get the current month (1 for January, 2 for February, ..., 12 for December)
    int currentMonth = DateTime.now().month;

    // Define a list of abbreviated month names
    List<String> monthNames = [
      "JAN",
      "FEB",
      "MAR",
      "APR",
      "MAY",
      "JUN",
      "JUL",
      "AUG",
      "SEP",
      "OCT",
      "NOV",
      "DEC"
    ];

    // Return the abbreviated name of the current month
    return monthNames[currentMonth - 1]; // Adjust for zero-based index
  }

  @override
  Widget build(BuildContext context) {
    print(checkTimeRange());
    print((showUpcomingRange()));
    print((getCurrentDay()));
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Stack(
              children: [
                Consumer(builder: (context, ref, child) {
                  final theme = ref.watch(themeModeProvider);
                  return Container(
                    margin: EdgeInsets.only(
                        left: MediaQuery.of(context).size.width * 0.1),
                    child: SvgPicture.asset(
                      theme == ThemeMode.dark
                          ? 'assets/students_dark.svg'
                          : 'assets/students_final.svg',
                      width: MediaQuery.of(context).size.width,
                    ),
                  );
                }),
                StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('timetable')
                        .doc(student.currentYear ?? "")
                        .collection(student.branch ?? "")
                        .where('day', isEqualTo: getCurrentDay())
                        .where(
                          'index',
                          isEqualTo: showUpcomingRange(),
                        )
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.data != null) {
                        var formattedDay = snapshot.data?.docs
                                .map((e) => e['day'])
                                .toString()
                                .substring(1, 4) ??
                            "${DateTime.now().day}";

                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return SizedBox();
                        }
                        if (snapshot.hasError) {
                          return const Text('');
                        }
                        if (snapshot.data!.docs.isEmpty) {
                          return const Text('No Data');
                        }
                        var data = snapshot.data?.docs[0];
                        return Consumer(builder: (context, ref, child) {
                          final theme = ref.watch(themeModeProvider);
                          return Positioned(
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
                                    color: theme == ThemeMode.dark
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  "$formattedDay ${DateTime.now().day} ${getCurrentMonth()}, \n${data?["startTime"]} PM" ??
                                      "",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 20,
                                    color: theme == ThemeMode.dark
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.5,
                                  child: Text(
                                    data?["subject"] ?? "",
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                      color: theme == ThemeMode.dark
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        });
                      } else {
                        return const Text('');
                      }
                    }),
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
                      StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('timetable')
                              .doc('Third Year')
                              .collection('Computer Engineering')
                              .where('day', isEqualTo: 'Monday')
                              .where(
                                'index',
                                isEqualTo: checkTimeRange(),
                              )
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.data != null) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Shimmer.fromColors(
                                  baseColor: Colors.grey.shade300,
                                  highlightColor: Colors.grey.shade100,
                                  child: DashBoardCard(
                                    color: Colors.green.shade50,
                                    subTitle: "No Class",
                                    title: "Current Lecture",
                                  ),
                                );
                              }
                              if (snapshot.hasError) {
                                return const Text('Something went wrong');
                              }
                              if (snapshot.data!.docs.isEmpty) {
                                return DashBoardCard(
                                  color: Colors.green.shade50,
                                  subTitle: "No Class",
                                  title: "Current Lecture",
                                );
                              }
                              var data = snapshot.data?.docs[0];
                              return DashBoardCard(
                                color: Colors.green.shade50,
                                subTitle: data?["subject"] ?? "",
                                title: "Current Lecture",
                              );
                            } else {
                              return DashBoardCard(
                                color: Colors.green.shade50,
                                subTitle: "No Class",
                                title: "Current Lecture",
                              );
                            }
                          }),
                      StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('attendance')
                              .where('branch', isEqualTo: student.branch)
                              .where('presentStudents',
                                  arrayContains: student.uid)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.data != null) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Shimmer.fromColors(
                                  baseColor: Colors.grey.shade300,
                                  highlightColor: Colors.grey.shade100,
                                  child: DashBoardCard(
                                    color: Colors.blue.shade50,
                                    subTitle: "75%",
                                    title: "Total Lec Attended",
                                  ),
                                );
                              }
                              if (snapshot.hasError) {
                                return const Text('Something went wrong');
                              }
                              if (snapshot.data!.docs.isEmpty) {
                                return DashBoardCard(
                                  color: Colors.blue.shade50,
                                  subTitle: "0",
                                  title: "Total Lec Attended",
                                );
                              }
                              var data = snapshot.data?.docs[0];
                              return DashBoardCard(
                                color: Colors.blue.shade50,
                                subTitle: "${data?["presentStudents"].length}",
                                title: "Total Lec Attended",
                              );
                            } else {
                              return DashBoardCard(
                                color: Colors.blue.shade50,
                                subTitle: "0",
                                title: "Total Attendance",
                              );
                            }
                          }),
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
                        subTitle: "20%",
                        title: "Total Attendance",
                      ),
                      DashBoardCard(
                        color: Colors.pink.shade50,
                        subTitle: "View All",
                        title: "Notes",
                      ),
                    ],
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.020,
                  ),
                  Consumer(builder: (context, ref, child) {
                    final theme = ref.watch(themeModeProvider);
                    return Text(
                      "Notice",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: theme == ThemeMode.dark
                            ? Colors.white
                            : Colors.black,
                      ),
                    );
                  }),
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
