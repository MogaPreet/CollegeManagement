import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cms/models/user.dart';
import 'package:cms/screens/Teacher/assignment.dart';
import 'package:cms/screens/Teacher/fetch_student.dart';
import 'package:cms/screens/Teacher/notice.dart';
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
  User? user = FirebaseAuth.instance.currentUser;
  TeacherModel loggedInUser = TeacherModel();

  @override
  void initState() {
    super.initState();
    FirebaseFirestore.instance
        .collection("teachers")
        .doc(user!.uid)
        .get()
        .then((value) {
      loggedInUser = TeacherModel.fromMap(value.data());
      setState(() {});
    });
  }

  Widget showSubject() {
    final sub = loggedInUser.subject;
    if (sub != null && sub.isNotEmpty) {
      final subject = sub.replaceAll(RegExp(r"\p{P}", unicode: true), " ");
      final a = subject.trim();
      List<String> subArrray = a.split("  ");
      return Column(
        children: subArrray.map((subjectName) {
          return Card(
            child: GestureDetector(
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AssignmentTeacherPage(
                            teacher: loggedInUser,
                            subject: subjectName,
                          ))),
              child: ListTile(
                title: Text(subjectName),
              ),
            ),
          );
        }).toList(),
      );
    }
    return const Text("Loading");
  }

  @override
  Widget build(BuildContext context) {
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
            showSubject(),
            const SizedBox(
              height: 20,
            ),
            FetchStudent(myBranch: loggedInUser.branch ?? ""),
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
  prefs.setBool('isTeacher', false);
}
