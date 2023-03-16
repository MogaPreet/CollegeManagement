import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class StudentAssignmentCard extends StatefulWidget {
  const StudentAssignmentCard({super.key});

  @override
  State<StudentAssignmentCard> createState() => _StudentAssignmentCardState();
}

class _StudentAssignmentCardState extends State<StudentAssignmentCard> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Card(
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
                children: const [
                  Text(
                    "Assignment Title",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Text(
                    "Subject name",
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.w300,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const Card(
            color: Color.fromRGBO(84, 84, 84, 1),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10))),
            margin: EdgeInsetsDirectional.only(
              start: 35,
              top: 5,
            ),
            child: Padding(
              padding: EdgeInsets.all(6.0),
              child: Text(
                "2 days left",
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ))
      ],
    );
  }
}
