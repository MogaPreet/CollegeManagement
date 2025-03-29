import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cms/models/subjects.dart';
import 'package:cms/models/user.dart';
import 'package:cms/screens/Student/widgets/progressIndicator.dart';
import 'package:cms/screens/Teacher/conditionalRoute.dart';
import 'package:cms/screens/Teacher/fetch_student.dart';
import 'package:cms/screens/Teacher/notice.dart';
import 'package:cms/screens/Teacher/show_assignment.dart';
import 'package:cms/screens/Teacher/text_to_speech/text_to_speech.dart';
import 'package:cms/screens/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TeacherHome extends StatefulWidget {
  const TeacherHome({super.key});

  @override
  State<TeacherHome> createState() => _TeacherHomeState();
}

class _TeacherHomeState extends State<TeacherHome> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  User? user = FirebaseAuth.instance.currentUser;
  TeacherModel loggedInUser = TeacherModel();
  CollectionReference teacher = FirebaseFirestore.instance.collection('teachers');
  bool isLoading = true;
  late AnimationController _animationController;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    _fetchTeacherData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  Future<void> _fetchTeacherData() async {
    try {
      final snapshot = await teacher.doc(user?.uid).get();
      if (snapshot.exists && snapshot.data() != null) {
        loggedInUser = TeacherModel.fromMap(snapshot.data());
      }
    } catch (e) {
      debugPrint("Error fetching teacher data: $e");
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Widget _buildAppBarTitle() {
    final titles = [
      "My Subjects",
      "My Students",
      "My Assignments"
    ];
    
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.0, 0.2),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: Text(
        titles[_currentIndex],
        key: ValueKey<int>(_currentIndex),
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildContentWidget() {
    switch (_currentIndex) {
      case 0:
        return SubjectPage(loggedInUser: loggedInUser);
      case 1:
        return FetchStudent(myBranch: loggedInUser.branch ?? []);
      case 2:
        return ShowAssignment(userId: loggedInUser.uid ?? "");
      default:
        return SubjectPage(loggedInUser: loggedInUser);
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: const [
              Icon(Icons.logout, color: Colors.red),
              SizedBox(width: 8),
              Text("Logout")
            ],
          ),
          content: const Text(
            "Are you sure you want to logout?",
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "CANCEL",
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () => logout(context),
              child: const Text(
                "LOGOUT",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey.shade900 : Colors.grey.shade50,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: isDarkMode ? Colors.grey.shade900 : Colors.white,
        title: _buildAppBarTitle(),
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
                backgroundColor: Colors.deepPurple.shade100,
                child: Text(
                  loggedInUser.firstName?.isNotEmpty == true 
                    ? loggedInUser.firstName![0].toUpperCase() 
                    : "T",
                  style: TextStyle(
                    color: Colors.deepPurple.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.record_voice_over,
              color: isDarkMode ? Colors.white : Colors.grey.shade800,
            ),
            tooltip: "Voice Lecture",
            onPressed: () {
              Navigator.push(
                context, 
                MaterialPageRoute(builder: (_) => LectureRecorderScreen())
              );
            },
          ),
          IconButton(
            icon: Icon(
              Icons.logout,
              color: isDarkMode ? Colors.white : Colors.grey.shade800,
            ),
            tooltip: "Logout",
            onPressed: _showLogoutDialog,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(
            height: 1,
            thickness: 1,
            color: isDarkMode 
              ? Colors.grey.shade800.withOpacity(0.5)
              : Colors.grey.shade200,
          ),
        ),
      ),
      body: isLoading
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  color: isDarkMode ? Colors.white70 : Colors.black87,
                ),
                const SizedBox(height: 16),
                Text(
                  "Loading your dashboard...",
                  style: TextStyle(
                    color: isDarkMode ? Colors.white70 : Colors.black54,
                  ),
                ),
              ],
            ),
          )
        : AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            child: _buildContentWidget(),
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.05, 0),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
          ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: isDarkMode ? Colors.deepPurple : Colors.black87,
        elevation: 4,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Notice(notifier: loggedInUser),
            ),
          );
        },
        icon: const Icon(Icons.add_comment_rounded, size: 20),
        label: const Text(
          "Add Notice",
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          child: BottomNavyBar(
            selectedIndex: _currentIndex,
            showElevation: false,
            itemCornerRadius: 16,
            curve: Curves.easeInOut,
            containerHeight: 65,
            onItemSelected: (index) {
              if (mounted) {
                setState(() => _currentIndex = index);
              }
            },
            items: [
              BottomNavyBarItem(
                icon: const Icon(Icons.school_rounded),
                title: const Text('Subjects'),
                textAlign: TextAlign.center,
                activeColor: isDarkMode ? Colors.deepPurple : Colors.black,
                inactiveColor: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700,
              ),
              BottomNavyBarItem(
                icon: const Icon(Icons.people_alt_rounded),
                title: const Text('Students'),
                textAlign: TextAlign.center,
                activeColor: isDarkMode ? Colors.deepPurple : Colors.black,
                inactiveColor: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700,
              ),
              BottomNavyBarItem(
                icon: const Icon(Icons.assignment_rounded),
                title: const Text('Assignments'),
                activeColor: isDarkMode ? Colors.deepPurple : Colors.black,
                inactiveColor: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SubjectPage extends StatelessWidget {
  const SubjectPage({
    Key? key,
    required this.loggedInUser,
  }) : super(key: key);

  final TeacherModel loggedInUser;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    if (loggedInUser.years == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.school_outlined,
              size: 64,
              color: isDarkMode ? Colors.grey.shade600 : Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              "No classes assigned yet",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: isDarkMode ? Colors.white70 : Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Your class assignments will appear here",
              style: TextStyle(
                fontSize: 14,
                color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }
    
    final yearOrder = {
      "First Year": 1,
      "Second Year": 2,
      "Third Year": 3,
      "Fourth Year": 4,
    };
    
    // Sort years in logical order
    final sortedYears = [...loggedInUser.years!]
      ..sort((a, b) => (yearOrder[a] ?? 99).compareTo(yearOrder[b] ?? 99));
    
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Icon(
                  Icons.person,
                  size: 16,
                  color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700,
                ),
                const SizedBox(width: 8),
                Text(
                  "Welcome, ${loggedInUser.firstName ?? 'Teacher'}",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isDarkMode ? Colors.grey.shade300 : Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text(
              "Your Classes",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
          ),
          const SizedBox(height: 8),
          
          // Years and subjects
          ...sortedYears.map((year) => ShowSubject(
              teacher: loggedInUser,
              year: year,
            )),
            
          const SizedBox(height: 80), // Space for FAB
        ],
      ),
    );
  }
}

class ShowSubject extends ConsumerStatefulWidget {
  final TeacherModel teacher;
  final String year;
  const ShowSubject({
    super.key,
    required this.teacher,
    required this.year,
  });

  @override
  ConsumerState<ShowSubject> createState() => _ShowSubjectState();
}

class _ShowSubjectState extends ConsumerState<ShowSubject> with SingleTickerProviderStateMixin {
  TeacherSubjects subject = TeacherSubjects();
  List<String> subjectsAll = [];
  bool isLoading = true;
  bool isExpanded = true;
  late AnimationController _controller;
  late Animation<double> _iconTurns;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 300), vsync: this);
    _iconTurns = Tween<double>(begin: 0.0, end: 0.5).animate(_controller);
    _fetchSubjects();
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  Future<void> _fetchSubjects() async {
    try {
      setState(() => isLoading = true);
      
      final snapshot = await FirebaseFirestore.instance
          .collection('teachers')
          .doc(widget.teacher.uid)
          .collection("subjects")
          .where("year", isEqualTo: widget.year)
          .get();
      
      if (snapshot.docs.isNotEmpty) {
        subject = TeacherSubjects.fromJson(snapshot.docs.first.data());
        subjectsAll = subject.subjects ?? [];
        // ref.read(mySubjects.notifier).update((state) => subject.subjects ?? []);
      }
    } catch (e) {
      debugPrint("Error fetching subjects: $e");
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }
  
  void _toggleExpanded() {
    setState(() {
      isExpanded = !isExpanded;
      if (isExpanded) {
        _controller.reverse();
      } else {
        _controller.forward();
      }
    });
  }

  String _getYearEmoji(String year) {
    switch (year) {
      case "First Year": return "🔰";
      case "Second Year": return "⭐";
      case "Third Year": return "🚀";
      case "Fourth Year": return "🎓";
      default: return "📚";
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final yearEmoji = _getYearEmoji(widget.year);
    
    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        elevation: 0,
        color: isDarkMode ? Colors.grey.shade800.withOpacity(0.5) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade200,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Year header with expand/collapse
            InkWell(
              onTap: _toggleExpanded,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Text(
                      yearEmoji,
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.year,
                      style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const Spacer(),
                    if (isLoading)
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: isDarkMode ? Colors.white70 : Colors.grey.shade600,
                        ),
                      )
                    else
                      Badge(
                        label: Text(
                          subjectsAll.length.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                        child: RotationTransition(
                          turns: _iconTurns,
                          child: Icon(
                            Icons.keyboard_arrow_down,
                            color: isDarkMode ? Colors.white70 : Colors.grey.shade700,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            
            // Divider
            if (isExpanded)
              Divider(
                height: 1,
                thickness: 1,
                color: isDarkMode ? Colors.grey.shade700.withOpacity(0.5) : Colors.grey.shade200,
              ),
              
            // Subject grid
            if (isExpanded)
              isLoading
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ),
                  )
                : subjectsAll.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            Icon(
                              Icons.book_outlined,
                              size: 48,
                              color: isDarkMode ? Colors.grey.shade600 : Colors.grey.shade400,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              "No subjects assigned yet",
                              style: TextStyle(
                                color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : GridView.builder(
                      shrinkWrap: true,
                      itemCount: subjectsAll.length,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(12),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.5,
                      ),
                      itemBuilder: (context, index) {
                        final subjectName = subjectsAll[index];
                        return _buildSubjectCard(context, subjectName, index);
                      },
                    ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSubjectCard(BuildContext context, String subjectName, int index) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final colors = [
      [Colors.blue.shade100, Colors.blue.shade200],
      [Colors.purple.shade100, Colors.purple.shade200],
      [Colors.teal.shade100, Colors.teal.shade200],
      [Colors.amber.shade100, Colors.amber.shade200],
      [Colors.pink.shade100, Colors.pink.shade200],
      [Colors.indigo.shade100, Colors.indigo.shade200],
      [Colors.green.shade100, Colors.green.shade200],
      [Colors.orange.shade100, Colors.orange.shade200],
    ];
    
    final colorIndex = index % colors.length;
    final cardColors = isDarkMode 
        ? [Colors.grey.shade700, Colors.grey.shade800] 
        : colors[colorIndex];
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OptionsForSubject(
                teacher: widget.teacher,
                subject: subjectName,
                year: widget.year,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: cardColors,
            ),
            boxShadow: [
              BoxShadow(
                color: cardColors.first.withOpacity(0.5),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Optional decorative elements
              Positioned(
                right: -10,
                bottom: -10,
                child: Opacity(
                  opacity: 0.08,
                  child: Icon(
                    Icons.book,
                    size: 80,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
              ),
              
              // Content
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        subjectName,
                        style: TextStyle(
                          color: isDarkMode ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.arrow_forward,
                          size: 16,
                          color: isDarkMode 
                              ? Colors.white70 
                              : Colors.black54,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "View Options",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: isDarkMode 
                                ? Colors.white70 
                                : Colors.black54,
                          ),
                        ),
                      ],
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
  try {
    await FirebaseAuth.instance.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    await prefs.setBool('isTeacher', false);
    
    if (context.mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen())
      );
    }
  } catch (e) {
    debugPrint("Error during logout: $e");
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Logout failed. Please try again."))
      );
    }
  }
}
