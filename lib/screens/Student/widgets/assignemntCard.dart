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

class AssignmentCard extends StatefulWidget {
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

  @override
  State<AssignmentCard> createState() => _AssignmentCardState();
}

class _AssignmentCardState extends State<AssignmentCard> {
  AssignmentResponseModel assignmentRes = AssignmentResponseModel();
  @override
  void initState() {
    super.initState();

    widget.colref
        .doc(widget.assignment.assignmentId)
        .collection("responses")
        .doc(widget.rollNo)
        .get()
        .then((value) {
      assignmentRes = AssignmentResponseModel.fromMap(value);
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    int daysBetween(DateTime from, DateTime to) {
      from = DateTime(from.year, from.month, from.day);
      to = DateTime(to.year, to.month, to.day);
      return (to.difference(from).inHours / 24).round();
    }

    DateTime? date = widget.assignment.getLastDate!.toDate();

    final difference = daysBetween(date, DateTime.now()).abs();

    return Stack(
      children: [
        if (assignmentRes.status != null && assignmentRes.status != "")
          Card(
            margin: const EdgeInsets.only(
              top: 115,
              left: 22,
            ),
            child: SizedBox(
              height: 30,
              width: 345,
              child: Center(
                child: Text(assignmentRes.status ?? "Assigned"),
              ),
            ),
          ),
        GestureDetector(
          onTap: () {
            if (assignmentRes.status?.toLowerCase() != "accepted") {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return ShowAssignments(
                  assigment: widget.assignment,
                  rollNo: widget.rollNo,
                  userId: widget.studentId,
                );
              }));
            }
          },
          child: Card(
            color: const Color.fromRGBO(32, 29, 27, 1),
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10))),
            margin: const EdgeInsets.all(20),
            child: SizedBox(
              height: 200,
              width: 400,
              child: Padding(
                padding: const EdgeInsetsDirectional.only(
                  top: 25,
                  start: 14,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.assignment.title ?? "",
                          softWrap: true,
                          maxLines: 1,
                          overflow: TextOverflow.fade,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 26,
                          ),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        Text(
                          widget.assignment.subject ?? "",
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
                    Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: Row(
                        children: [
                          Text(
                            widget.assignment.assignedBy ?? "",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w300,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Text(
                            widget.assignment.assignedDate?.hour.toString() ??
                                "",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w300,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (assignmentRes.status?.toLowerCase() != "accepted")
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
                "Due in $difference days",
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          )
      ],
    );
  }
}

class ShowStatus extends StatefulWidget {
  final AssignMentModel assignment;
  final CollectionReference colref;
  final String studentId;
  final String rollNo;
  const ShowStatus({
    super.key,
    required this.assignment,
    required this.colref,
    required this.studentId,
    required this.rollNo,
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
        .doc(widget.rollNo)
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
