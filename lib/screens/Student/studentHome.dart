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
import 'package:intl/intl.dart';

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
        return "Hey, ${student.firstName ?? ""} 👋";
      case 1:
        return "Assignment 🎒";
      case 2:
        return "Events 🎉";
      case 3:
        return 'Profile 🧑🏻‍🎓';
      default:
        return "Home";
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = ref.watch(selectedIndexProvider);
    final theme = ref.watch(themeModeProvider);
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
        selectedItemColor:
            theme == ThemeMode.dark ? Colors.white : Colors.black,
        unselectedItemColor:
            theme == ThemeMode.dark ? Colors.grey.shade700 : Colors.grey,
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
    final theme = ref.watch(themeModeProvider);
    
    Future<void> refreshTimetable() async {
      ref.invalidate(studentProvider);
      ref.invalidate(timetableProvider);
      await Future.delayed(const Duration(milliseconds: 500));
    }

    return RefreshIndicator(
      onRefresh: refreshTimetable,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Enhanced Hero Section
            _buildEnhancedHeroSection(context, timetableSnapshot, theme),
            
            // Quick Action Buttons
            _buildQuickActionButtons(context, theme,ref),
            
            // Rest of content
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.05,
                vertical: 10,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Current class and stats cards
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        flex: 1,
                        child: _buildCurrentClassCard(currenttimetableSnapshot, theme),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        flex: 1,
                        child: DashBoardCard(
                          color: theme == ThemeMode.dark 
                              ? Colors.blue.shade900.withOpacity(0.3)
                              : Colors.blue.shade50,
                          subTitle: "0",
                          title: "Total Lec Attended",
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: MediaQuery.of(context).size.height * 0.015),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        flex: 1,
                        child: DashBoardCard(
                          color: theme == ThemeMode.dark 
                              ? Colors.purple.shade900.withOpacity(0.3)
                              : Colors.purple.shade50,
                          subTitle: "20%",
                          title: "Total Attendance",
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        flex: 1,
                        child: DashBoardCard(
                          color: theme == ThemeMode.dark 
                              ? Colors.pink.shade900.withOpacity(0.3)
                              : Colors.pink.shade50,
                          subTitle: "View All",
                          title: "Notes",
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: MediaQuery.of(context).size.height * 0.020),
                  
                  // Section Header with Animation
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 800),
                    builder: (context, value, child) {
                      return Transform.translate(
                        offset: Offset(0, 20 * (1 - value)),
                        child: Opacity(
                          opacity: value,
                          child: child,
                        ),
                      );
                    },
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: theme == ThemeMode.dark
                                ? Colors.orange.withOpacity(0.2)
                                : Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.campaign_rounded,
                            color: theme == ThemeMode.dark
                                ? Colors.orange.shade300
                                : Colors.orange.shade700,
                            size: 20,
                          ),
                        ),
                        SizedBox(width: 10),
                        Text(
                          "Announcements",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Notice Section
                  student.when(
                    data: (student) {
                      return StudNotice(
                          mybranch: student.branch ?? 'Default Branch');
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
    );
  }

  // Enhanced Hero Section with animated weather card and next class
  Widget _buildEnhancedHeroSection(
      BuildContext context, AsyncValue<QuerySnapshot> timetableSnapshot, ThemeMode theme) {
    // Get current time and date
    final now = DateTime.now();
    final greeting = _getGreeting();
    final formattedDate = DateFormat('EEEE, d MMMM').format(now);
    
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.32,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: theme == ThemeMode.dark
              ? [Colors.indigo.shade900, Colors.blue.shade900]
              : [Colors.indigo.shade400, Colors.blue.shade500],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Stack(
        children: [
          // Background Elements
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            left: -40,
            bottom: -40,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          
          // Content
          Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date and Weather Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Date display with animation
                    TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0, end: 1),
                      duration: const Duration(milliseconds: 600),
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: value,
                          child: Transform.translate(
                            offset: Offset(-20 * (1 - value), 0),
                            child: child,
                          ),
                        );
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            greeting,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            formattedDate,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Weather card with animation
                    TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0, end: 1),
                      duration: const Duration(milliseconds: 800),
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: value,
                          child: Transform.translate(
                            offset: Offset(20 * (1 - value), 0),
                            child: child,
                          ),
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.wb_sunny_rounded,
                              color: Colors.amber,
                              size: 20,
                            ),
                            SizedBox(width: 5),
                            Text(
                              "28°C",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: 20),
                
                // Next Class Section
                Expanded(
                  child: timetableSnapshot.when(
                    data: (snapshot) {
                      if (snapshot.docs.isEmpty) {
                        return _buildEmptyNextClass();
                      }
                      var data = snapshot.docs[0];
                      
                      return TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0, end: 1),
                        duration: const Duration(milliseconds: 1000),
                        builder: (context, value, child) {
                          return Opacity(
                            opacity: value,
                            child: Transform.translate(
                              offset: Offset(0, 30 * (1 - value)),
                              child: child,
                            ),
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header
                              Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      Icons.school_rounded,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    "Next Class",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              
                              Spacer(),
                              
                              // Class details
                              Text(
                                data["subject"] ?? "No Subject",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 6),
                              Row(
                                children: [
                                  Icon(
                                    Icons.access_time_rounded,
                                    color: Colors.white.withOpacity(0.8),
                                    size: 16,
                                  ),
                                  SizedBox(width: 5),
                                  Text(
                                    "${data["startTime"]} - ${data["endTime"]}",
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.8),
                                      fontSize: 14,
                                    ),
                                  ),
                                  SizedBox(width: 16),
                                  Icon(
                                    Icons.room_rounded,
                                    color: Colors.white.withOpacity(0.8),
                                    size: 16,
                                  ),
                                  SizedBox(width: 5),
                                  Text(
                                    data["room"] ?? "TBD",
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.8),
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              
                              Spacer(),
                              
                              // Time remaining
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Starts in",
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.7),
                                      fontSize: 13,
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      _calculateTimeRemaining(data["startTime"]),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    loading: () => Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    ),
                    error: (e, stack) => Center(
                      child: Text(
                        'Error loading schedule',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyNextClass() {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 800),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_available_rounded,
              color: Colors.white,
              size: 40,
            ),
            SizedBox(height: 10),
            Text(
              "No more classes today",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 6),
            Text(
              "Enjoy your free time!",
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButtons(BuildContext context, ThemeMode theme,WidgetRef ref) {
    return Container(
      margin: EdgeInsets.only(top: -30),
      padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.05),
      child: Card(
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: theme == ThemeMode.dark ? Colors.grey.shade900 : Colors.white,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionButton(
                context,
                icon: Icons.assignment_rounded,
                label: "Assignments",
                color: Colors.blue,
                onTap: () {
                  ref.read(selectedIndexProvider.notifier).state = 1;
                },
              ),
              _buildActionButton(
                context,
                icon: Icons.event_rounded,
                label: "Events",
                color: Colors.purple,
                onTap: () {
                  ref.read(selectedIndexProvider.notifier).state = 2;
                },
              ),
              _buildActionButton(
                context,
                icon: Icons.menu_book_rounded,
                label: "Materials",
                color: Colors.orange,
                onTap: () {
                  // Navigate to materials page
                },
              ),
              _buildActionButton(
                context,
                icon: Icons.chat_rounded,
                label: "Chat",
                color: Colors.green,
                onTap: () {
                  // Navigate to chat page
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          SizedBox(height: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentClassCard(AsyncValue<QuerySnapshot> currenttimetableSnapshot, ThemeMode theme) {
    return currenttimetableSnapshot.when(
      data: (snapshot) {
        if (snapshot.docs.isEmpty) {
          return DashBoardCard(
            color: theme == ThemeMode.dark 
                ? Colors.green.shade900.withOpacity(0.3)
                : Colors.green.shade50,
            subTitle: "No Class",
            title: "Current Lecture",
          );
        } else {
          var data = snapshot.docs[0];
          return DashBoardCard(
            color: theme == ThemeMode.dark 
                ? Colors.green.shade900.withOpacity(0.3)
                : Colors.green.shade50,
            subTitle: data["subject"] ?? "No Class",
            title: "Current Lecture",
          );
        }
      },
      loading: () => Shimmer.fromColors(
        baseColor: theme == ThemeMode.dark ? Colors.grey.shade800 : Colors.grey.shade300,
        highlightColor: theme == ThemeMode.dark ? Colors.grey.shade700 : Colors.grey.shade100,
        child: DashBoardCard(
          color: theme == ThemeMode.dark 
              ? Colors.green.shade900.withOpacity(0.3)
              : Colors.green.shade50,
          subTitle: "Loading...",
          title: "Current Lecture",
        ),
      ),
      error: (e, st) => DashBoardCard(
        color: Colors.red.shade50,
        subTitle: "Error loading class",
        title: "Current Lecture",
      ),
    );
  }

  // Helper method to get appropriate greeting based on time of day
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  // Helper method to calculate time remaining until class
  String _calculateTimeRemaining(String? startTimeString) {
    if (startTimeString == null) return "Soon";
    
    try {
      // Parse the start time (assuming format like "9:30 AM")
      final parts = startTimeString.split(' ');
      final timeParts = parts[0].split(':');
      int hour = int.parse(timeParts[0]);
      final int minute = int.parse(timeParts[1]);
      
      // Handle AM/PM
      if (parts.length > 1 && parts[1].toUpperCase() == 'PM' && hour < 12) {
        hour += 12;
      } else if (parts.length > 1 && parts[1].toUpperCase() == 'AM' && hour == 12) {
        hour = 0;
      }
      
      // Create class start time
      final now = DateTime.now();
      final startTime = DateTime(
        now.year, 
        now.month, 
        now.day, 
        hour, 
        minute
      );
      
      // If class already started or is in past, return "Now"
      if (startTime.isBefore(now)) {
        return "Now";
      }
      
      // Calculate difference
      final difference = startTime.difference(now);
      final hours = difference.inHours;
      final minutes = difference.inMinutes % 60;
      
      if (hours > 0) {
        return "${hours}h ${minutes}m";
      } else {
        return "${minutes}m";
      }
    } catch (e) {
      return "Soon";
    }
  }
}

Future<void> logout(BuildContext context) async {
  await FirebaseAuth.instance.signOut();
  final prefs = await SharedPreferences.getInstance();
  prefs.setBool('isLoggedIn', false);
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(
      builder: (context) => const LoginScreen(),
    ),
    (x) => false,
  );
}

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
