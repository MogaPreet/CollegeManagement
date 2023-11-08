import 'package:cms/models/user.dart';
import 'package:cms/screens/Teacher/assignment.dart';
import 'package:cms/screens/Teacher/attendence.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OptionsForSubject extends StatelessWidget {
  final TeacherModel teacher;
  final String? subject;

  final String year;
  const OptionsForSubject({
    super.key,
    required this.teacher,
    required this.subject,
    required this.year,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(subject ?? ""),
        backgroundColor: const Color.fromARGB(255, 37, 37, 37),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 24, right: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return AssignmentTeacherPage(
                        teacher: teacher,
                        subject: subject,
                        year: year,
                      );
                    },
                  ),
                );
              },
              child: Container(
                height: 180,
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color.fromARGB(255, 103, 103, 107),
                        Color.fromARGB(255, 168, 166, 180),
                        Color.fromARGB(255, 93, 92, 94),
                        Color.fromARGB(255, 10, 10, 10),
                      ],
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(
                        16))), // Adds a gradient background and rounded corners to the container
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.add_task,
                          color: Colors.white,
                          size: 60,
                        ),
                      ],
                    ),
                    Text('Asssignment',
                        style: TextStyle(
                            fontSize: 24,
                            color: Colors
                                .white)) // Adds a price to the bottom of the card
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 16,
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return AttendancePage(
                        myBranch: teacher.branch ?? [],
                        currentYear: year,
                      );
                    },
                  ),
                );
              },
              child: Container(
                height: 180,
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color.fromARGB(255, 103, 103, 107),
                        Color.fromARGB(255, 168, 166, 180),
                        Color.fromARGB(255, 93, 92, 94),
                        Color.fromARGB(255, 10, 10, 10),
                      ],
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(
                        16))), // Adds a gradient background and rounded corners to the container
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.people_outline_sharp,
                          color: Colors.white,
                          size: 60,
                        ),
                      ],
                    ),
                    Text('Attendance',
                        style: TextStyle(
                            fontSize: 24,
                            color: Colors
                                .white)) // Adds a price to the bottom of the card
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
