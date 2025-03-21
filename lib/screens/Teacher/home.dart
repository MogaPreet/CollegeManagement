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

class _TeacherHomeState extends State<TeacherHome> {
  int _currentIndex = 0;
  User? user = FirebaseAuth.instance.currentUser;
  TeacherModel loggedInUser = TeacherModel();
  CollectionReference teacher =
      FirebaseFirestore.instance.collection('teachers');
  @override
  void initState() {
    super.initState();

    teacher.doc(user?.uid).get().then((value) {
      loggedInUser = TeacherModel.fromMap(value.data());
      setState(() {});
    });
  }

  // Widget showSubject() {
  //   print("branch ${loggedInUser.branch}");

  //   int? val = loggedInUser.branch?.length;
  //   return ListView.builder(
  //       shrinkWrap: true,
  //       itemCount: val,
  //       itemBuilder: (context, index) {
  //         // if (loggedInUser.branch != null) {
  //         //   final subject = loggedInUser.branch
  //         //       ?.map(
  //         //         (e) => e,
  //         //       )
  //         //       .toString();
  //         //   return ListTile(
  //         //     title: Text(subject ?? "Subject"),
  //         //   );
  //         // }
  //         return const Text("Loading ...");
  //       });
  // }
  Widget appBarText() {
    switch (_currentIndex) {
      case 0:
        return const Text(
          "My Subjects",
          style: TextStyle(
            fontSize: 16,
          ),
        );
      case 1:
        return const Text(
          "My Students",
          style: TextStyle(
            fontSize: 16,
          ),
        );
      case 2:
        return const Text(
          "My Assignments",
          style: TextStyle(
            fontSize: 16,
          ),
        );
      default:
    }
    return const Text("Something went Wrong");
  }

  Widget showWidget() {
    switch (_currentIndex) {
      case 0:
        return SubjectPage(
          loggedInUser: loggedInUser,
        );

      case 1:
        return FetchStudent(myBranch: loggedInUser.branch ?? []);
      case 2:
        return ShowAssignment(userId: loggedInUser.uid ?? "");
    }
    return SubjectPage(loggedInUser: loggedInUser);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavyBar(
        selectedIndex: _currentIndex,
        showElevation: false,
        itemCornerRadius: 16,
        curve: Curves.easeIn,
        onItemSelected: (index) {
          if (mounted) setState(() => _currentIndex = index);
        },
        items: <BottomNavyBarItem>[
          BottomNavyBarItem(
            icon: const Icon(Icons.apps),
            title: const Text(
              'Subjects',
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
            textAlign: TextAlign.center,
            activeColor: Colors.black,
            inactiveColor: Colors.grey.shade700,
          ),
          BottomNavyBarItem(
            icon: const Icon(Icons.people),
            title: const Text(
              'Students',
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
            textAlign: TextAlign.center,
            activeColor: Colors.black,
            inactiveColor: Colors.grey.shade700,
          ),
          BottomNavyBarItem(
            icon: const Icon(Icons.note_rounded),
            title: const Text(
              'Assignments',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            activeColor: Colors.black,
            inactiveColor: Colors.grey.shade700,
            textAlign: TextAlign.center,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.black26,
        elevation: 0,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => Notice(
                      notifier: loggedInUser,
                    )),
          );
        },
        label: const Text("Add Notice"),
        icon: const Icon(Icons.edit),
      ),
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (c) {
                  return LectureRecorderScreen();
                }));
              },
              icon: Icon(Icons.record_voice_over)),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text("Logout"),
                      content: const Text("Are you sure you want to logout?"),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text("No"),
                        ),
                        TextButton(
                          onPressed: () {
                            logout(context);
                          },
                          child: const Text("Yes"),
                        ),
                      ],
                    );
                  });
            },
          ),
        ],
        title: appBarText(),
      ),
      body: showWidget(),
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
    return (loggedInUser.years != null)
        ? SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    if (loggedInUser.years!.contains("First Year"))
                      ShowSubject(
                        teacher: loggedInUser,
                        year: "First Year",
                      ),
                    if (loggedInUser.years!.contains("Second Year"))
                      ShowSubject(
                        teacher: loggedInUser,
                        year: "Second Year",
                      ),
                    if (loggedInUser.years!.contains("Third Year"))
                      ShowSubject(
                        teacher: loggedInUser,
                        year: "Third Year",
                      ),
                    if (loggedInUser.years!.contains("Fourth Year"))
                      ShowSubject(
                        teacher: loggedInUser,
                        year: "Fourth Year",
                      ),
                    const SizedBox(
                      height: 20,
                    ),
                  ],
                )),
          )
        : const Center(child: CircularProgressIndicator());
  }
}

final mySubjects = StateProvider<List<String>>((ref) {
  return [];
});

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

class _ShowSubjectState extends ConsumerState<ShowSubject> {
  TeacherSubjects subject = TeacherSubjects();
  List<String> subjectsAll = [];

  List<String> getDetails() {
    FirebaseFirestore.instance
        .collection('teachers')
        .doc(widget.teacher.uid)
        .collection("subjects")
        .where("year", isEqualTo: widget.year)
        .get()
        .then((value) {
      for (var i in value.docs) {
        subject = TeacherSubjects.fromJson(i.data());
        setState(() {});
        break;
      }
      subjectsAll = subject.subjects ?? [];
      ref.watch(mySubjects.notifier).update((state) => subject.subjects ?? []);
    });
    return subjectsAll;
  }

  @override
  Widget build(BuildContext context) {
    final mysubs = getDetails();

    int? val = mysubs.length;
    Widget gridWidget = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Text(
            widget.year,
            style: TextStyle(
              color: Colors.grey.shade900,
              fontWeight: FontWeight.w400,
              fontSize: 18,
            ),
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          itemCount: val,
          physics: const BouncingScrollPhysics(),
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return OptionsForSubject(
                        teacher: widget.teacher,
                        subject: subject.subjects?[index],
                        year: widget.year,
                      );
                    },
                  ),
                );
              },
              child: Card(
                elevation: 4,
                shadowColor: Colors.black12.withOpacity(0.1),
                color: Colors.black12.withOpacity(0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Center(
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.7,
                      child: Text(
                        subject.subjects![index],
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color.fromARGB(255, 37, 37, 37),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
          padding: const EdgeInsets.all(8),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 2,
            childAspectRatio: 1.5,
            mainAxisSpacing: 2,
          ),
        ),
      ],
    );
    if (mysubs.isNotEmpty) {
      return gridWidget;
    }
    return ProgressIndication(
      child: gridWidget,
    );
  }
}

Future<void> logout(BuildContext context) async {
  await FirebaseAuth.instance.signOut();

  Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginScreen()));
  final prefs = await SharedPreferences.getInstance();
  prefs.setBool('isLoggedIn', false);
  prefs.setBool('isTeacher', false);
}
