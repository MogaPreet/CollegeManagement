import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cms/models/user.dart';
import 'package:cms/screens/Student/create_event.dart';
import 'package:cms/screens/Student/eventListpage.dart';
import 'package:cms/screens/Student/utils/time_utils.dart';
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

class StudentHomePage extends ConsumerStatefulWidget {
  const StudentHomePage({super.key});

  @override
  ConsumerState<StudentHomePage> createState() => _StudentHomePageState();
}

class _StudentHomePageState extends ConsumerState<StudentHomePage> {
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

  String showAppBarText(int currentIndex) {
    switch (currentIndex) {
      case 0:
        return "Hey, ${student.firstName ?? ""}";
      case 1:
        return "Assignment";
      case 2:
        return "Events";
      case 3:
        return 'Profile';
      default:
        return "Home";
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = ref.watch(selectedIndexProvider);
    List<Widget> pages = <Widget>[
      const Home(),
      StudentAssignmentCard(
        student: student,
      ),
      EventListPage(),
      StudentCard(student: student),
    ];
    return Scaffold(
      bottomSheet: selectedIndex == 3
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
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        elevation: 0,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        onTap: (index) {
          ref.read(selectedIndexProvider.notifier).state = index;
        },
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
            icon: Icon(Icons.event),
            label: 'Events',
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
        actions: [
          if (selectedIndex == 2)
            IconButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return CreateEventPage();
                  }));
                },
                icon: Icon(Icons.add_box_rounded))
        ],
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
      body: pages.elementAt(selectedIndex),
    );
  }
}

class Home extends ConsumerWidget {
  const Home({Key? key}) : super(key: key);

  String getCurrentDay() {
    DateTime now = DateTime.now();
    List<String> daysOfWeek = [
      "Sunday",
      "Monday",
      "Tuesday",
      "Wednesday",
      "Thursday",
      "Friday",
      "Saturday",
      "Sunday"
    ];
    return daysOfWeek[DateTime.now().weekday];
  }

  String getCurrentMonth() {
    int currentMonth = DateTime.now().month;
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
    return monthNames[currentMonth - 1];
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final student = ref.watch(studentProvider);
    final timetableSnapshot = ref.watch(timetableProvider(getCurrentDay()));
    final currenttimetableSnapshot =
        ref.watch(currenttimetableProvider(getCurrentDay()));
    Future<void> refreshTimetable() async {
      // Invalidate the providers to trigger a refresh
      ref.invalidate(studentProvider);
      ref.invalidate(timetableProvider);
      await Future.delayed(const Duration(milliseconds: 500));
    }

    return RefreshIndicator(
      onRefresh: refreshTimetable,
      child: SingleChildScrollView(
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
                  timetableSnapshot.when(
                    data: (snapshot) {
                      if (snapshot.docs.isEmpty) {
                        return const Center(
                          child: Text("Nothing here"),
                        );
                      }
                      var data = snapshot.docs[0];

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
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.color,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "${data["day"]}, \n${data["startTime"]}",
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 20,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.color,
                              ),
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.5,
                              child: Text(
                                data["subject"] ?? "",
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                  fontWeight: FontWeight.w300,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.color,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    loading: () => Positioned(
                      left: MediaQuery.of(context).size.width * 0.05,
                      top: MediaQuery.of(context).size.height * 0.10,
                      child: Shimmer.fromColors(
                        baseColor: Colors.grey.shade300,
                        highlightColor: Colors.grey.shade100,
                        child: DashBoardCard(
                          color: Colors.green.shade50,
                          subTitle: "Loading...",
                          title: "Next Class",
                        ),
                      ),
                    ),
                    error: (e, stack) => const Text('Error fetching data'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Other Widgets and StreamBuilders
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
                        currenttimetableSnapshot.when(
                          data: (snapshot) {
                            if (snapshot.docs.isEmpty) {
                              return DashBoardCard(
                                color: Colors.green.shade50,
                                subTitle: "No Class",
                                title: "Current Lecture",
                              );
                            } else {
                              var data = snapshot.docs[0];
                              return DashBoardCard(
                                color: Colors.green.shade50,
                                subTitle: data["subject"] ?? "No Class",
                                title: "Current Lecture",
                              );
                            }
                          },
                          loading: () => Shimmer.fromColors(
                            baseColor: Colors.grey.shade300,
                            highlightColor: Colors.grey.shade100,
                            child: DashBoardCard(
                              color: Colors.green.shade50,
                              subTitle: "Loading...",
                              title: "Current Lecture",
                            ),
                          ),
                          error: (e, st) => DashBoardCard(
                            color: Colors.red.shade50,
                            subTitle: "Error loading class",
                            title: "Current Lecture",
                          ),
                        ),
                        DashBoardCard(
                          color: Colors.blue.shade50,
                          subTitle: "0",
                          title: "Total Lec Attended",
                        ),
                      ],
                    ),
                    SizedBox(
                        height: MediaQuery.of(context).size.height * 0.015),
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
                        height: MediaQuery.of(context).size.height * 0.020),
                    Text(
                      "Notice",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    student.when(
                      data: (student) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Other widgets
                            StudNotice(
                                mybranch: student.branch ?? 'Default Branch'),
                          ],
                        );
                      },
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (error, stack) =>
                          Center(child: Text('Error: $error')),
                    ),
                  ],
                ),
              ),
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

// Provider to fetch student data

// Provider to fetch student data
final studentProvider = FutureProvider<StudentModel>((ref) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    throw Exception("No user logged in");
  }

  try {
    final doc = await FirebaseFirestore.instance
        .collection('students')
        .doc(user.uid)
        .get();
    if (doc.exists) {
      return StudentModel.fromMap(doc.data()!);
    } else {
      throw Exception("Student data not found");
    }
  } catch (e) {
    throw Exception("Failed to fetch student data: $e");
  }
});

final timetableProvider =
    StreamProvider.autoDispose.family<QuerySnapshot, String>((ref, day) {
  final studentAsyncValue = ref.watch(studentProvider);

  return studentAsyncValue.when(
    data: (student) {
      return FirebaseFirestore.instance
          .collection('timetable')
          .doc(student.currentYear ?? "")
          .collection(student.branch ?? "")
          .where('day', isEqualTo: day)
          .where('index', isEqualTo: TimeUtils.getUpcomingRangeIndex())
          .snapshots();
    },
    loading: () {
      // Return an empty stream while loading
      return const Stream.empty();
    },
    error: (error, stack) {
      // Handle error and return a stream with an error
      return Stream.error(error);
    },
  );
});

final currenttimetableProvider =
    StreamProvider.autoDispose.family<QuerySnapshot, String>((ref, day) {
  final studentAsyncValue = ref.watch(studentProvider);

  return studentAsyncValue.when(
    data: (student) {
      // Ensure that the student object is not null
      print("Current time range: ${TimeUtils.getCurrentRangeIndex()}");
      print("upcoming time range: ${TimeUtils.getUpcomingRangeIndex()}");
      return FirebaseFirestore.instance
          .collection('timetable')
          .doc(student.currentYear ?? "")
          .collection(student.branch ?? "")
          .where('day', isEqualTo: day)
          .where('index', isEqualTo: TimeUtils.getCurrentRangeIndex())
          .snapshots();
    },
    loading: () {
      // Return an empty stream while loading
      return const Stream.empty();
    },
    error: (error, stack) {
      // Handle error and return a stream with an error
      return Stream.error(error);
    },
  );
});

final selectedIndexProvider = StateProvider<int>((ref) => 0);
