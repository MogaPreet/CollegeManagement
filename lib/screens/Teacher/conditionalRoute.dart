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
        titleSpacing: 0,
        toolbarHeight: 100,
        centerTitle: true,
        backgroundColor: Colors.black12,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(24),
            bottomRight: Radius.circular(24),
          ),
        ),
        title: Text(
          subject ?? "",
          style: const TextStyle(overflow: TextOverflow.ellipsis),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
        ),
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
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
                          Colors.black54,
                          Colors.black45,
                          Colors.black38,
                          Colors.black26,
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
                      Text('Add Asssignment',
                          style: TextStyle(
                              fontSize: 24,
                              color: Colors
                                  .white)) // Adds a price to the bottom of the card
                    ],
                  ),
                ),
              ),
              const SizedBox(
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
                          subject: subject ?? "",
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
                          Colors.black26,
                          Colors.black38,
                          Colors.black45,
                          Colors.black54,
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
              const SizedBox(
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
                          subject: subject ?? "",
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
                          Colors.black26,
                          Colors.black38,
                          Colors.black45,
                          Colors.black54,
                        ],
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(
                          16))), // Adds a gradient background and rounded corners to the container
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.home_max,
                            color: Colors.white,
                            size: 60,
                          ),
                        ],
                      ),
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.8,
                        ),
                        child: FittedBox(
                          fit: BoxFit.fitWidth,
                          child: Text(
                            'Upload Video Refernces',
                            style: TextStyle(
                              fontSize: 24,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ) // Adds a price to the bottom of the card
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
