import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cms/models/assignment.dart';
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
      // Replace the bottom sheet in the Scaffold with this improved version

// Replace the existing bottomSheet with this improved version

      bottomSheet: selectedIndex == 3
          ? Container(
              height: MediaQuery.of(context).size.height *
                  0.30, // Increased height for better visibility
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: theme == ThemeMode.dark
                      ? [Colors.grey.shade900, Colors.black]
                      : [Colors.white, Colors.grey.shade50],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Handle/pill for bottom sheet
                  Container(
                    margin: const EdgeInsets.only(top: 12, bottom: 16),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme == ThemeMode.dark
                          ? Colors.grey.shade700
                          : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  // Title with icon
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: theme == ThemeMode.dark
                                ? Colors.indigo.withOpacity(0.2)
                                : Colors.indigo.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.settings_rounded,
                            color: theme == ThemeMode.dark
                                ? Colors.indigo.shade200
                                : Colors.indigo,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Text(
                          'Settings',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: theme == ThemeMode.dark
                                ? Colors.white
                                : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Settings items in a scrollable list
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      physics: const BouncingScrollPhysics(),
                      children: [
                        // Appearance section with animation
                        TweenAnimationBuilder<double>(
                          tween: Tween<double>(begin: 0, end: 1),
                          duration: const Duration(milliseconds: 400),
                          builder: (context, value, child) {
                            return Opacity(
                              opacity: value,
                              child: Transform.translate(
                                offset: Offset(0, 10 * (1 - value)),
                                child: child,
                              ),
                            );
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionHeader('Appearance'),
                              _buildSettingsTile(
                                title: 'Dark Mode',
                                icon: theme == ThemeMode.dark
                                    ? Icons.dark_mode_rounded
                                    : Icons.light_mode_rounded,
                                iconColor: theme == ThemeMode.dark
                                    ? Colors.amber
                                    : Colors.indigo,
                                trailing: Consumer(
                                  builder: (context, ref, _) {
                                    final themeMode =
                                        ref.watch(themeModeProvider);
                                    return Switch.adaptive(
                                      value: themeMode == ThemeMode.dark,
                                      activeColor: Colors.indigo,
                                      onChanged: (value) {
                                        ref
                                                .read(themeModeProvider.notifier)
                                                .state =
                                            value
                                                ? ThemeMode.dark
                                                : ThemeMode.light;
                                      },
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),

                        const Divider(height: 32),

                        // Notifications section with animation
                        TweenAnimationBuilder<double>(
                          tween: Tween<double>(begin: 0, end: 1),
                          duration: const Duration(milliseconds: 600),
                          builder: (context, value, child) {
                            return Opacity(
                              opacity: value,
                              child: Transform.translate(
                                offset: Offset(0, 10 * (1 - value)),
                                child: child,
                              ),
                            );
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionHeader('Notifications'),
                              _buildSettingsTile(
                                title: 'Push Notifications',
                                subtitle: 'Receive updates and alerts',
                                icon: Icons.notifications_none_rounded,
                                iconColor: Colors.amber,
                                trailing: Switch.adaptive(
                                  value: true,
                                  activeColor: Colors.indigo,
                                  onChanged: (value) {
                                    // Implement notification toggle
                                  },
                                ),
                              ),
                              _buildSettingsTile(
                                title: 'Email Notifications',
                                subtitle: 'Get updates via email',
                                icon: Icons.mark_email_unread_outlined,
                                iconColor: Colors.green,
                                trailing: Switch.adaptive(
                                  value: false,
                                  activeColor: Colors.indigo,
                                  onChanged: (value) {
                                    // Implement email notification toggle
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),

                        const Divider(height: 32),

                        // Support & About section with animation
                        TweenAnimationBuilder<double>(
                          tween: Tween<double>(begin: 0, end: 1),
                          duration: const Duration(milliseconds: 800),
                          builder: (context, value, child) {
                            return Opacity(
                              opacity: value,
                              child: Transform.translate(
                                offset: Offset(0, 10 * (1 - value)),
                                child: child,
                              ),
                            );
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionHeader('Support & About'),
                              _buildSettingsTile(
                                title: 'Privacy Policy',
                                icon: Icons.shield_outlined,
                                iconColor: Colors.blue,
                                onTap: () {
                                  // Navigate to privacy policy
                                },
                              ),
                              _buildSettingsTile(
                                title: 'About Us',
                                subtitle: 'Learn more about our team',
                                icon: Icons.info_outline_rounded,
                                iconColor: Colors.purple,
                                onTap: () {
                                  // Navigate to about us
                                },
                              ),
                              _buildSettingsTile(
                                title: 'FAQs',
                                subtitle: 'Get answers to common questions',
                                icon: Icons.help_outline_rounded,
                                iconColor: Colors.teal,
                                onTap: () {
                                  // Navigate to FAQs
                                },
                              ),
                            ],
                          ),
                        ),

                        const Divider(height: 32),

                        // Account section with animation
                        TweenAnimationBuilder<double>(
                          tween: Tween<double>(begin: 0, end: 1),
                          duration: const Duration(milliseconds: 1000),
                          builder: (context, value, child) {
                            return Opacity(
                              opacity: value,
                              child: Transform.translate(
                                offset: Offset(0, 10 * (1 - value)),
                                child: child,
                              ),
                            );
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionHeader('Account'),

                              // Logout button
                              _buildSettingsTile(
                                title: 'Logout',
                                subtitle: 'Sign out from your account',
                                icon: Icons.logout_rounded,
                                iconColor: Colors.red,
                                titleColor: Colors.red,
                                onTap: () => _showLogoutConfirmation(context),
                              ),
                            ],
                          ),
                        ),

                        // Version info with animation
                        TweenAnimationBuilder<double>(
                          tween: Tween<double>(begin: 0, end: 1),
                          duration: const Duration(milliseconds: 1200),
                          builder: (context, value, child) {
                            return Opacity(
                              opacity: value,
                              child: child,
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 24),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: theme == ThemeMode.dark
                                        ? Colors.grey.shade800
                                        : Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.android_rounded,
                                        size: 14,
                                        color: theme == ThemeMode.dark
                                            ? Colors.grey.shade400
                                            : Colors.grey.shade700,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Version 1.5.5',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: theme == ThemeMode.dark
                                              ? Colors.grey.shade400
                                              : Colors.grey.shade700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          : null,
      bottomNavigationBar: Container(
  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
  decoration: BoxDecoration(
    color: theme == ThemeMode.dark ? Colors.grey.shade900 : Colors.white,
    borderRadius: BorderRadius.circular(24),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        blurRadius: 20,
        offset: const Offset(0, 5),
      ),
    ],
  ),
  child: ClipRRect(
    borderRadius: BorderRadius.circular(24),
    child: BottomNavigationBar(
      backgroundColor: Colors.transparent,
      currentIndex: selectedIndex,
      selectedItemColor: theme == ThemeMode.dark 
          ? Colors.indigo.shade200 
          : Colors.indigo.shade700,
      unselectedItemColor: theme == ThemeMode.dark 
          ? Colors.grey.shade600 
          : Colors.grey.shade400,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      selectedLabelStyle: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 11,
      ),
      unselectedLabelStyle: const TextStyle(
        fontSize: 10,
      ),
      onTap: (index) {
        ref.read(selectedIndexProvider.notifier).state = index;
      },
      items: [
        _buildNavItem(
          icon: Icons.home_rounded, 
          label: 'Home',
          selectedIndex: selectedIndex,
          itemIndex: 0,
          theme: theme,
        ),
        _buildNavItem(
          icon: Icons.assignment_rounded, 
          label: 'Tasks',
          selectedIndex: selectedIndex,
          itemIndex: 1,
          theme: theme,
        ),
        _buildNavItem(
          icon: Icons.event_rounded, 
          label: 'Events',
          selectedIndex: selectedIndex,
          itemIndex: 2,
          theme: theme,
        ),
        _buildNavItem(
          icon: Icons.person_rounded, 
          label: 'Profile',
          selectedIndex: selectedIndex,
          itemIndex: 3,
          theme: theme,
        ),
      ],
    ),
  ),
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

  // Add these utility methods to the _StudentHomePageState class

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.indigo,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required String title,
    String? subtitle,
    required IconData icon,
    Color iconColor = Colors.indigo,
    Color? titleColor,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    final theme = ref.watch(themeModeProvider);
    final isDark = theme == ThemeMode.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? Colors.black12 : Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                if (!isDark)
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: titleColor ??
                              (isDark ? Colors.white : Colors.black87),
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? Colors.grey.shade400
                                : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (trailing != null) trailing,
                if (onTap != null && trailing == null)
                  Icon(
                    Icons.chevron_right_rounded,
                    color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.logout_rounded,
                  color: Colors.red.shade400,
                  size: 32,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Logout',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Are you sure you want to logout from your account?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.red.shade400,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        logout(context);
                      },
                      child: const Text('Logout'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Add this helper method to the studentHome.dart file
BottomNavigationBarItem _buildNavItem({
  required IconData icon,
  required String label,
  required int selectedIndex,
  required int itemIndex,
  required ThemeMode theme,
}) {
  final isSelected = selectedIndex == itemIndex;
  final isDark = theme == ThemeMode.dark;
  
  return BottomNavigationBarItem(
    icon: Column(
      children: [
        Container(
          height: 3,
          width: 20,
          margin: const EdgeInsets.only(bottom: 5),
          decoration: BoxDecoration(
            color: isSelected 
                ? (isDark ? Colors.indigo.shade200 : Colors.indigo.shade700)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.all(isSelected ? 8 : 6),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? Colors.indigo.withOpacity(0.2) : Colors.indigo.withOpacity(0.1))
                : Colors.transparent,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: isSelected ? 24 : 22,
          ),
        ),
      ],
    ),
    activeIcon: Column(
      children: [
        Container(
          height: 3,
          width: 20,
          margin: const EdgeInsets.only(bottom: 5),
          decoration: BoxDecoration(
            color: isDark ? Colors.indigo.shade200 : Colors.indigo.shade700,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDark ? Colors.indigo.withOpacity(0.2) : Colors.indigo.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 24,
          ),
        ),
      ],
    ),
    label: label,
  );
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
            _buildQuickActionButtons(context, theme, ref),

            // Rest of content
            // Replace the content section with this enhanced version
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.05,
                vertical: 10,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Daily Overview Section
                  _buildSectionHeader(
                    title: "Today's Overview",
                    icon: Icons.today_rounded,
                    color: Colors.indigo,
                    theme: theme,
                    context: context,
                  ),

                  const SizedBox(height: 15),

                  // Current Class and Attendance Overview
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: theme == ThemeMode.dark
                            ? [
                                Colors.grey.shade900,
                                Colors.grey.shade900.withOpacity(0.8)
                              ]
                            : [Colors.white, Colors.grey.shade50],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        if (theme != ThemeMode.dark)
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                            spreadRadius: 0,
                          ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Current class with enhanced design
                        _buildEnhancedCurrentClassCard(
                            currenttimetableSnapshot, theme, context),

                        const SizedBox(height: 16),
                        const Divider(height: 1),
                        const SizedBox(height: 16),

                        // Attendance stats row
                        Row(
                          children: [
                            // Total Lectures Attended
                            Expanded(
                              child: _buildAttendanceStat(
                                title: "Lectures Attended",
                                value: "32",
                                icon: Icons.how_to_reg_rounded,
                                color: Colors.blue,
                                theme: theme,
                              ),
                            ),

                            // Divider
                            Container(
                              height: 40,
                              width: 1,
                              color: theme == ThemeMode.dark
                                  ? Colors.grey.shade800
                                  : Colors.grey.shade300,
                            ),

                            // Attendance Percentage
                            Expanded(
                              child: _buildAttendanceStat(
                                title: "Total Attendance",
                                value: "78%",
                                icon: Icons.bar_chart_rounded,
                                color: Colors.green,
                                theme: theme,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  // Academic Resources Section
                  _buildSectionHeader(
                    title: "Academic Resources",
                    icon: Icons.school_rounded,
                    color: Colors.purple,
                    theme: theme,
                    context: context,
                  ),

                  const SizedBox(height: 15),

                  // Resource Cards Row
                  Row(
                    children: [
                      // Assignments Card
                      Expanded(
                        child: _buildResourceCard(
                          title: "Assignments",
                          value: "5",
                          subtitle: "2 due soon",
                          icon: Icons.assignment_outlined,
                          color: Colors.orange,
                          theme: theme,
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Notes Card
                      Expanded(
                        child: _buildResourceCard(
                          title: "Notes",
                          value: "24",
                          subtitle: "View All",
                          icon: Icons.note_alt_outlined,
                          color: Colors.pink,
                          theme: theme,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),

                  // Announcements Section
                  _buildSectionHeader(
                    title: "Announcements",
                    icon: Icons.campaign_rounded,
                    color: Colors.amber,
                    theme: theme,
                    context: context,
                  ),

                  const SizedBox(height: 10),

                  // Notice Section
                  // Enhanced Announcements Container with Card-based UI
// Enhanced Announcements Container with Card-based UI and Dialog View All
Container(
  height: 300, // Slightly increased height for better readability
  decoration: BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: theme == ThemeMode.dark
          ? [Colors.grey.shade900, Colors.grey.shade800]
          : [Colors.white, Colors.grey.shade50],
    ),
    borderRadius: BorderRadius.circular(20),
    boxShadow: [
      if (theme != ThemeMode.dark)
        BoxShadow(
          color: Colors.black.withOpacity(0.07),
          blurRadius: 15,
          offset: const Offset(0, 5),
          spreadRadius: 0,
        ),
    ],
  ),
  child: Stack(
    children: [
      // Background pattern (subtle grid)
      if (theme != ThemeMode.dark)
        Positioned.fill(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Opacity(
              opacity: 0.05,
              child: Image.network(
                'https://www.transparenttextures.com/patterns/cubes.png',
                repeat: ImageRepeat.repeat,
              ),
            ),
          ),
        ),
      
      // Corner decoration
      Positioned(
        top: -35,
        right: -35,
        child: Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: Colors.amber.withOpacity(theme == ThemeMode.dark ? 0.1 : 0.07),
            shape: BoxShape.circle,
          ),
        ),
      ),
      
      // Content
      Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: theme == ThemeMode.dark 
                      ? Colors.grey.shade800 
                      : Colors.grey.shade200,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Latest Announcements',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: theme == ThemeMode.dark 
                        ? Colors.white 
                        : Colors.black87,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.amber.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.notifications_active_rounded,
                        size: 12,
                        color: theme == ThemeMode.dark 
                            ? Colors.amber.shade300 
                            : Colors.amber.shade700,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'Important',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: theme == ThemeMode.dark 
                              ? Colors.amber.shade300 
                              : Colors.amber.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Notices Content
          Expanded(
            child: student.when(
              data: (student) {
                return ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                  child: Stack(
                    children: [
                      // Main content
                      StudNotice(mybranch: student.branch ?? 'Default Branch'),
                    ],
                  ),
                );
              },
              loading: () => Center(
                child: CircularProgressIndicator(
                  color: theme == ThemeMode.dark 
                      ? Colors.amber.shade300 
                      : Colors.amber.shade700,
                  strokeWidth: 2,
                ),
              ),
              error: (error, stack) {
                return _buildSimpleErrorState(error.toString(), theme);
              },
            ),
          ),
        ],
      ),
      
      // View all button at bottom
      Positioned(
        bottom: 0,
        left: 0,
        right: 0,
        child: Container(
          height: 45,
          decoration: BoxDecoration(
            color: theme == ThemeMode.dark 
                ? Colors.grey.shade800.withOpacity(0.5) 
                : Colors.grey.shade50.withOpacity(0.8),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
            border: Border.all(
              color: theme == ThemeMode.dark 
                  ? Colors.grey.shade700 
                  : Colors.grey.shade200,
              width: 0.5,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                // Show full announcements dialog instead of navigating
                student.whenData((studentData) {
                  _showAnnouncementsDialog(context, studentData.branch ?? 'Default Branch', theme);
                });
              },
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(19.5),
                bottomRight: Radius.circular(19.5),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'View All Announcements',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: theme == ThemeMode.dark 
                          ? Colors.amber.shade300 
                          : Colors.amber.shade700,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 16,
                    color: theme == ThemeMode.dark 
                        ? Colors.amber.shade300 
                        : Colors.amber.shade700,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ],
  ),
),


                  // Bottom spacing for better scrolling experience
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Enhanced Hero Section with animated weather card and next class
  Widget _buildEnhancedHeroSection(BuildContext context,
      AsyncValue<QuerySnapshot> timetableSnapshot, ThemeMode theme) {
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
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                                    data["classroom"] ?? "TBD",
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                                      _calculateTimeRemaining(
                                          data["startTime"]),
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

  Widget _buildQuickActionButtons(
      BuildContext context, ThemeMode theme, WidgetRef ref) {
    return Container(
      // margin: EdgeInsets.only(top: -30),
      padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.05),
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

  Widget _buildCurrentClassCard(
      AsyncValue<QuerySnapshot> currenttimetableSnapshot, ThemeMode theme) {
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
        baseColor: theme == ThemeMode.dark
            ? Colors.grey.shade800
            : Colors.grey.shade300,
        highlightColor: theme == ThemeMode.dark
            ? Colors.grey.shade700
            : Colors.grey.shade100,
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
      } else if (parts.length > 1 &&
          parts[1].toUpperCase() == 'AM' &&
          hour == 12) {
        hour = 0;
      }

      // Create class start time
      final now = DateTime.now();
      final startTime = DateTime(now.year, now.month, now.day, hour, minute);

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

// Method to show full announcements dialog
void _showAnnouncementsDialog(BuildContext context, String branch, ThemeMode theme) {
  final isDark = theme == ThemeMode.dark;
  
  showDialog(
    context: context,
    builder: (context) => Dialog(
      backgroundColor: isDark ? Colors.grey.shade900 : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
        child: Column(
          children: [
            // Dialog Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark 
                      ? [Colors.amber.shade900, Colors.amber.shade800]
                      : [Colors.amber.shade400, Colors.amber.shade300],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.campaign_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'All Announcements',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.close_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
            
            // Content
            Expanded(
              child: StudNotice(mybranch: branch,),
            ),
            
            // Bottom note
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              child: Text(
                'Notices are ordered by most recent first',
                style: TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

// Simple error state widget for announcements section
Widget _buildSimpleErrorState(String error, ThemeMode theme) {
  final isDark = theme == ThemeMode.dark;
  
  return Center(
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.announcement_rounded,
            color: isDark ? Colors.amber.shade300 : Colors.amber.shade700,
            size: 40,
          ),
          const SizedBox(height: 16),
          Text(
            "Unable to load announcements",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: isDark ? Colors.white : Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            "Pull down to refresh",
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}

// Shimmer loading state specifically designed for announcements
Widget _buildAnnouncementsShimmer(ThemeMode theme) {
  final isDark = theme == ThemeMode.dark;
  
  return Shimmer.fromColors(
    baseColor: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
    highlightColor: isDark ? Colors.grey.shade700 : Colors.grey.shade100,
    child: Padding(
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(
          4,
          (index) => Padding(
            padding: const EdgeInsets.only(bottom: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      width: 130,
                      height: 15,
                      color: Colors.white,
                    ),
                    const Spacer(),
                    Container(
                      width: 60,
                      height: 15,
                      color: Colors.white,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  height: 12,
                  color: Colors.white,
                ),
                const SizedBox(height: 5),
                Container(
                  width: 50,
                  height: 12,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

// Error state specifically designed for announcements
Widget _buildAnnouncementsError(String errorMessage, ThemeMode theme, BuildContext context) {
  final isDark = theme == ThemeMode.dark;
  
  return Center(
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(isDark ? 0.2 : 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.wifi_off_rounded,
              color: isDark ? Colors.red.shade300 : Colors.red.shade700,
              size: 30,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "Couldn't Load Announcements",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            errorMessage.length > 50 
                ? "Connection error. Pull down to refresh."
                : errorMessage,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
          const SizedBox(height: 15),
          OutlinedButton.icon(
            onPressed: () {
              // Trigger refresh
              context.findAncestorStateOfType<_StudentHomePageState>()?.setState(() {});
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: isDark ? Colors.amber.shade300 : Colors.amber.shade700,
              side: BorderSide(
                color: isDark ? Colors.amber.shade300 : Colors.amber.shade700,
                width: 1.5,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text("Try Again"),
          ),
        ],
      ),
    ),
  );
}


// Skeleton loading state for resource cards
Widget _buildResourceCardSkeleton(String title, IconData icon, Color color, bool isDark) {
  return Shimmer.fromColors(
    baseColor: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
    highlightColor: isDark ? Colors.grey.shade700 : Colors.grey.shade100,
    child: Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: isDark ? Colors.grey.shade900 : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: 30,
              height: 22,
              color: Colors.white,
            ),
            const SizedBox(height: 10),
            Container(
              width: 70,
              height: 14,
              color: Colors.white,
            ),
            const SizedBox(height: 6),
            Container(
              width: 50,
              height: 12,
              color: Colors.white,
            ),
          ],
        ),
      ),
    ),
  );
}

// Error state for resource cards
Widget _buildResourceCardError(String title, IconData icon, Color color, bool isDark) {
  return Card(
    elevation: isDark ? 0 : 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: isDark ? BorderSide(color: Colors.red.shade900, width: 1) : BorderSide.none,
    ),
    color: isDark ? Colors.grey.shade900 : Colors.white,
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(isDark ? 0.2 : 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 20,
              color: isDark ? Colors.red.shade300 : Colors.red.shade700,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "N/A",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            "Couldn't load data",
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.red.shade300 : Colors.red.shade700,
            ),
          ),
        ],
      ),
    ),
  );
}
// Add these helper methods to the Home class in studentHome.dart

// Enhanced Section Header with Animation
Widget _buildSectionHeader({
  required String title,
  required IconData icon,
  required Color color,
  required ThemeMode theme,
  required BuildContext context,
}) {
  final isDark = theme == ThemeMode.dark;
  
  return TweenAnimationBuilder<double>(
    tween: Tween<double>(begin: 0, end: 1),
    duration: const Duration(milliseconds: 800),
    builder: (context, value, child) {
      return Transform.translate(
        offset: Offset(0, 10 * (1 - value)),
        child: Opacity(
          opacity: value,
          child: child,
        ),
      );
    },
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(isDark ? 0.2 : 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color.withOpacity(isDark ? 0.3 : 0.2),
              width: 1.5,
            ),
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
      ],
    ),
  );
}

// Enhanced Current Class Card with Better Visual Design
Widget _buildEnhancedCurrentClassCard(
    AsyncValue<QuerySnapshot> currenttimetableSnapshot, ThemeMode theme, BuildContext context) {
  final isDark = theme == ThemeMode.dark;
  
  return currenttimetableSnapshot.when(
    data: (snapshot) {
      if (snapshot.docs.isEmpty) {
        // No current class
        return _buildCurrentClassStatus(
          icon: Icons.free_breakfast_rounded,
          title: "No Current Lecture",
          subtitle: "You're free right now",
          theme: theme,
          backgroundGradient: isDark
              ? [Colors.teal.shade900.withOpacity(0.5), Colors.teal.shade900.withOpacity(0.2)]
              : [Colors.teal.shade50, Colors.teal.shade100],
          iconColor: isDark ? Colors.teal.shade300 : Colors.teal.shade700,
        );
      } else {
        // Has current class
        var data = snapshot.docs[0].data() as Map<String, dynamic>;
        final subject = data["subject"] ?? "Unknown Class";
        final room = data["classroom"] ?? data["classroom"] ?? "TBD";
        final teacher = data["teacher"] ?? "Faculty";
        final startTime = data["startTime"] ?? "";
        final endTime = data["endTime"] ?? "";
        
        return _buildCurrentClassStatus(
          icon: Icons.school_rounded,
          title: subject,
          subtitle: "Room $room • $startTime-$endTime",
          theme: theme,
          backgroundGradient: isDark
              ? [Colors.green.shade900.withOpacity(0.5), Colors.green.shade900.withOpacity(0.2)]
              : [Colors.green.shade50, Colors.green.shade100],
          iconColor: isDark ? Colors.green.shade300 : Colors.green.shade700,
          showButton: true,
          buttonText: "Check In",
          onButtonPressed: () {
            // Show class check-in dialog or navigate to attendance page
          },
          additionalInfo: teacher,
        );
      }
    },
    loading: () => Shimmer.fromColors(
      baseColor: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
      highlightColor: isDark ? Colors.grey.shade700 : Colors.grey.shade100,
      child: _buildCurrentClassStatus(
        icon: Icons.schedule_rounded,
        title: "Loading...",
        subtitle: "Please wait",
        theme: theme,
        backgroundGradient: isDark
            ? [Colors.grey.shade800, Colors.grey.shade900]
            : [Colors.grey.shade100, Colors.grey.shade200],
        iconColor: Colors.grey,
      ),
    ),
    error: (e, st) => _buildCurrentClassStatus(
      icon: Icons.error_outline_rounded,
      title: "Couldn't Load Class",
      subtitle: "Try refreshing the page",
      theme: theme,
      backgroundGradient: isDark
          ? [Colors.red.shade900.withOpacity(0.5), Colors.red.shade900.withOpacity(0.2)]
          : [Colors.red.shade50, Colors.red.shade100],
      iconColor: isDark ? Colors.red.shade300 : Colors.red.shade700,
    ),
  );
}

// Current Class Status Widget
Widget _buildCurrentClassStatus({
  required IconData icon,
  required String title,
  required String subtitle,
  required ThemeMode theme,
  required List<Color> backgroundGradient,
  required Color iconColor,
  bool showButton = false,
  String buttonText = "",
  VoidCallback? onButtonPressed,
  String? additionalInfo,
}) {
  final isDark = theme == ThemeMode.dark;
  
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: backgroundGradient,
      ),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon with circular background
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDark 
                    ? Colors.black.withOpacity(0.2) 
                    : Colors.white.withOpacity(0.6),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 22,
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Title and subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                  if (additionalInfo != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      "By $additionalInfo",
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.white70 : Colors.black54,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        
        // Button if needed
        if (showButton) ...[
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onButtonPressed,
              style: ElevatedButton.styleFrom(
                foregroundColor: isDark ? Colors.white : Colors.white,
                backgroundColor: isDark 
                    ? Colors.green.shade700.withOpacity(0.7) 
                    : Colors.green.shade600,
                padding: const EdgeInsets.symmetric(vertical: 12),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                buttonText,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ],
    ),
  );
}

// Attendance Stat Item
Widget _buildAttendanceStat({
  required String title,
  required String value,
  required IconData icon,
  required Color color,
  required ThemeMode theme,
}) {
  final isDark = theme == ThemeMode.dark;
  
  return Column(
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: color,
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ],
      ),
      const SizedBox(height: 4),
      Text(
        title,
        style: TextStyle(
          fontSize: 12,
          color: isDark ? Colors.white60 : Colors.black54,
        ),
        textAlign: TextAlign.center,
      ),
    ],
  );
}

// Resource Card (Notes, Assignments)
// Resource Card (Notes, Assignments) - Updated with dynamic data and fixed context
Widget _buildResourceCard({
  required String title,
  required String value,
  required String subtitle,
  required IconData icon,
  required Color color,
  required ThemeMode theme,
}) {
  final isDark = theme == ThemeMode.dark;
  
  // For assignments, fetch real data from Firebase
  if (title == "Assignments") {
    return Consumer(
      builder: (context, ref, child) {
        final student = ref.watch(studentProvider);
        
        return student.when(
          data: (studentData) {
            return StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('assignments')
                  .where("toBranch", isEqualTo: studentData.branch)
                  .where("year", isEqualTo: studentData.currentYear)
                  .snapshots(),
              builder: (context, snapshot) {
                // Loading state
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildResourceCardSkeleton(title, icon, color, isDark);
                }
                
                // Error state
                if (snapshot.hasError) {
                  return _buildResourceCardError(title, icon, color, isDark);
                }
                
                // Data state
                final assignmentCount = snapshot.data?.docs.length ?? 0;
                int pendingCount = 0;
                
                // Calculate pending assignments
                for (var doc in snapshot.data?.docs ?? []) {
                  final data = doc.data() as Map<String, dynamic>;
                  final assignment = AssignMentModel.fromMap(data);
                  final dueDate = assignment.getLastDate?.toDate();
                  
                  if (dueDate != null && dueDate.isAfter(DateTime.now())) {
                    pendingCount++;
                  }
                }
                
                return _buildResourceCardContent(
                  title: title, 
                  value: assignmentCount.toString(), 
                  subtitle: pendingCount > 0 ? "$pendingCount due soon" : "No pending tasks",
                  icon: icon, 
                  color: color, 
                  isDark: isDark,
                  context: context,
                  onTap: () {
                    ref.read(selectedIndexProvider.notifier).state = 1; // Navigate to assignments tab
                  }
                );
              },
            );
          },
          loading: () => _buildResourceCardSkeleton(title, icon, color, isDark),
          error: (_, __) => _buildResourceCardError(title, icon, color, isDark),
        );
      },
    );
  } 
  // For notes, could be implemented similarly with real data
  else if (title == "Notes") {
    return Builder(
      builder: (context) => _buildResourceCardContent(
        title: title, 
        value: value, 
        subtitle: subtitle,
        icon: icon, 
        color: color, 
        isDark: isDark,
        context: context,
        onTap: () {
          // Navigate to notes section or show dialog that it's coming soon
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Coming Soon'),
              content: const Text('Notes feature will be available in the next update.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      ),
    );
  }
  // Default fallback
  else {
    return Builder(
      builder: (context) => _buildResourceCardContent(
        title: title, 
        value: value, 
        subtitle: subtitle,
        icon: icon, 
        color: color, 
        isDark: isDark,
        context: context
      ),
    );
  }
}
// Extracted card content for reusability
// Extracted card content for reusability with fixed context parameter
Widget _buildResourceCardContent({
  required String title,
  required String value,
  required String subtitle,
  required IconData icon,
  required Color color,
  required bool isDark,
  required BuildContext context,
  VoidCallback? onTap,
}) {
  return Card(
    elevation: isDark ? 0 : 4,
    shadowColor: isDark ? Colors.transparent : Colors.black12,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: isDark 
          ? BorderSide(color: Colors.grey.shade800, width: 1) 
          : BorderSide.none,
    ),
    color: isDark ? Colors.grey.shade900 : Colors.white,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon with container
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(isDark ? 0.2 : 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 20,
                color: color,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Main value (count)
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            
            const SizedBox(height: 6),
            
            // Title and subtitle
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
            
            const SizedBox(height: 2),
            
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: color,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
// Skeleton loading state for resource cards


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
