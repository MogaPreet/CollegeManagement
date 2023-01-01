import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cms/models/user.dart';
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

  @override
  Widget build(BuildContext context) {
    print(loggedInUser.branch);
    return Scaffold(
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
        actions: [
          IconButton(
            onPressed: () {
              logout(context);
            },
            icon: const Icon(Icons.logout),
          )
        ],
        title: loggedInUser.firstName != null
            ? Text(loggedInUser.firstName ?? "")
            : const CircularProgressIndicator(),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'My Subjects',
              ),
            ),
            ShowSubject(
              teacher: loggedInUser,
            ),
            const SizedBox(
              height: 20,
            ),
            FetchStudent(myBranch: loggedInUser.branch ?? [""]),
          ],
        ),
      ),
    );
  }
}

class ShowSubject extends StatefulWidget {
  final TeacherModel teacher;
  const ShowSubject({super.key, required this.teacher});

  @override
  State<ShowSubject> createState() => _ShowSubjectState();
}

class _ShowSubjectState extends State<ShowSubject> {
  @override
  Widget build(BuildContext context) {
    print("branch ${widget.teacher.subject}");

    int? val = widget.teacher.subject?.length;
    if (widget.teacher.subject != null && widget.teacher.subject!.isNotEmpty) {
      return ListView.builder(
          shrinkWrap: true,
          itemCount: val,
          itemBuilder: (context, index) {
            return ListTile(
                trailing: GestureDetector(
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return AssignmentTeacherPage(
                            teacher: widget.teacher,
                            subject: widget.teacher.subject![index]);
                      }));
                    },
                    child: const Text("Assign Asignment")),
                title: Text(
                  widget.teacher.subject![index],
                ));
          });
    }
    return const CircularProgressIndicator();
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
