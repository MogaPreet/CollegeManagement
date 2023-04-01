import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cms/models/assignment.dart';
import 'package:cms/models/user.dart';
import 'package:cms/screens/Student/studentAssignment.dart';
import 'package:flutter/material.dart';

class StudentAssignmentCard extends StatefulWidget {
  final StudentModel student;
  const StudentAssignmentCard({super.key, required this.student});

  @override
  State<StudentAssignmentCard> createState() => _StudentAssignmentCardState();
}

class _StudentAssignmentCardState extends State<StudentAssignmentCard> {
  AssignMentModel assignment = AssignMentModel();

  @override
  Widget build(BuildContext context) {
    CollectionReference c =
        FirebaseFirestore.instance.collection('assignments');
    return StreamBuilder<QuerySnapshot>(
      stream: c
          .where("toBranch", isEqualTo: widget.student.branch)
          .where("year", isEqualTo: widget.student.currentYear)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('Something went wrong');
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              color: Colors.black,
            ),
          );
        }
        var len = snapshot.data?.docs.length ?? 0;
        return len < 1
            ? const Center(
                child: Text("No Assignment Found"),
              )
            : ListView.builder(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                itemCount: len,
                itemBuilder: ((context, index) {
                  final DocumentSnapshot documentSnapshot =
                      snapshot.data!.docs[index];
                  assignment = AssignMentModel.fromMap(documentSnapshot);
                  return AssignmentCard(
                    assignment: assignment,
                    rollNo: widget.student.rollNo ?? "",
                    studentId: widget.student.uid ?? "",
                    colref: c,
                  );
                }));
      },
    );
  }
}

class AssignmentCard extends StatelessWidget {
  final String studentId;
  final String rollNo;
  final CollectionReference colref;
  AssignmentCard({
    Key? key,
    required this.assignment,
    required this.studentId,
    required this.rollNo,
    required this.colref,
  }) : super(key: key);

  final AssignMentModel assignment;
  AssignmentResponseModel assignmentRes = AssignmentResponseModel();

  @override
  Widget build(BuildContext context) {
    int daysBetween(DateTime from, DateTime to) {
      from = DateTime(from.year, from.month, from.day);
      to = DateTime(to.year, to.month, to.day);
      return (to.difference(from).inHours / 24).round();
    }

    DateTime? date = assignment.getLastDate!.toDate();
    final difference = daysBetween(date, DateTime.now()).abs();

    return Stack(
      children: [
        ShowStatus(
          assignment: assignment,
          colref: colref,
          studentId: studentId,
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return ShowAssignments(
                assigment: assignment,
                rollNo: rollNo,
                userId: studentId,
              );
            }));
          },
          child: Card(
            color: const Color.fromRGBO(32, 29, 27, 1),
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10))),
            margin: const EdgeInsets.all(20),
            child: SizedBox(
              height: 100,
              width: 400,
              child: Padding(
                padding: const EdgeInsetsDirectional.only(
                  top: 25,
                  start: 14,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      assignment.title ?? "",
                      softWrap: true,
                      maxLines: 1,
                      overflow: TextOverflow.fade,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Text(
                      assignment.subject ?? "",
                      maxLines: 1,
                      overflow: TextOverflow.fade,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.w300,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Card(
            color: const Color.fromRGBO(84, 84, 84, 1),
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10))),
            margin: const EdgeInsetsDirectional.only(
              start: 35,
              top: 5,
            ),
            child: Padding(
              padding: const EdgeInsets.all(6.0),
              child: Text(
                "$difference days left",
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ))
      ],
    );
  }
}

class ShowStatus extends StatefulWidget {
  final AssignMentModel assignment;
  final CollectionReference colref;
  final String studentId;
  const ShowStatus({
    super.key,
    required this.assignment,
    required this.colref,
    required this.studentId,
  });

  @override
  State<ShowStatus> createState() => _ShowStatusState();
}

class _ShowStatusState extends State<ShowStatus> {
  AssignmentResponseModel assignRes = AssignmentResponseModel();
  @override
  void initState() {
    super.initState();

    widget.colref
        .doc(widget.assignment.assignmentId)
        .collection("responses")
        .doc(widget.studentId)
        .get()
        .then((value) {
      assignRes = AssignmentResponseModel.fromMap(value);
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(
        top: 115,
        left: 22,
      ),
      child: SizedBox(
        height: 25,
        width: 345,
        child: Center(
          child: Text(assignRes.status ?? "Assigned"),
        ),
      ),
    );
  }
}
