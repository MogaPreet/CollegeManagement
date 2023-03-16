import 'package:cms/models/assignment.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class ShowAssignments extends StatefulWidget {
  final AssignMentModel assigment;
  const ShowAssignments({super.key, required this.assigment});

  @override
  State<ShowAssignments> createState() => _ShowAssignmentsState();
}

class _ShowAssignmentsState extends State<ShowAssignments> {
  @override
  Widget build(BuildContext context) {
    var url = Uri(path: widget.assigment.url);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("Assignment Detail"),
      ),
      body: Padding(
        padding: const EdgeInsetsDirectional.only(
          start: 14,
          top: 8,
          end: 14,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.assigment.title ?? "",
              textAlign: TextAlign.start,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            const Divider(),
            Text(
              widget.assigment.desc ?? "",
              textAlign: TextAlign.justify,
              maxLines: 6,
              overflow: TextOverflow.fade,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            const Text(
              "Reference Document",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(url.path),
          ],
        ),
      ),
    );
  }
}
