import 'dart:convert';
import 'dart:math';

import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cms/models/subjects.dart';
import 'package:cms/models/user.dart';
import 'package:cms/screens/Student/studentHome.dart';
import 'package:cms/screens/Student/widgets/progressIndicator.dart';
import 'package:cms/screens/Teacher/assignment.dart';
import 'package:cms/screens/Teacher/fetch_student.dart';
import 'package:cms/screens/Teacher/notice.dart';
import 'package:cms/screens/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
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
        return const Text("My Subjects");
      case 1:
        return const Text("My Students");
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
    }
    return SubjectPage(loggedInUser: loggedInUser);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavyBar(
        selectedIndex: _currentIndex,
        showElevation: true,
        itemCornerRadius: 24,
        curve: Curves.easeIn,
        backgroundColor: Colors.black,
        onItemSelected: (index) {
          if (mounted) setState(() => _currentIndex = index);
        },
        items: <BottomNavyBarItem>[
          BottomNavyBarItem(
            icon: const Icon(Icons.apps),
            title: const Text('Subjects'),
            activeColor: Colors.red,
            textAlign: TextAlign.center,
          ),
          BottomNavyBarItem(
            icon: const Icon(Icons.people),
            title: const Text('Students'),
            activeColor: Colors.purpleAccent,
            textAlign: TextAlign.center,
          ),
          BottomNavyBarItem(
            icon: const Icon(Icons.message),
            title: const Text(
              'Messages test for mes teset test test ',
            ),
            activeColor: Colors.pink,
            textAlign: TextAlign.center,
          ),
          BottomNavyBarItem(
            icon: const Icon(Icons.settings),
            title: const Text('Settings'),
            activeColor: Colors.blue,
            textAlign: TextAlign.center,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
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
        centerTitle: true,
        backgroundColor: Colors.black87,
        actions: [
          IconButton(
            onPressed: () {
              logout(context);
            },
            icon: const Icon(Icons.logout),
          )
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
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: (loggedInUser.years != null)
            ? Column(
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
              )
            : const Center(child: CircularProgressIndicator()),
      ),
    );
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
              fontWeight: FontWeight.w800,
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
                      return AssignmentTeacherPage(
                        teacher: widget.teacher,
                        subject: subject.subjects?[index],
                        year: widget.year,
                      );
                    },
                  ),
                );
              },
              child: Card(
                elevation: 6,
                shadowColor: Colors.grey.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Center(
                    child: Text(
                      subject.subjects![index],
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 14,
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
