import 'package:cms/models/assignment.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_file_view/flutter_file_view.dart';

import 'package:url_launcher/link.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

class ShowAssignments extends StatefulWidget {
  final AssignMentModel assigment;
  const ShowAssignments({super.key, required this.assigment});

  @override
  State<ShowAssignments> createState() => _ShowAssignmentsState();
}

class _ShowAssignmentsState extends State<ShowAssignments> {
  @override
  Widget build(BuildContext context) {
    final Uri url = Uri.parse(widget.assigment.url ?? "");
    Future<void> _launchInBrowser(Uri url) async {
      await canLaunchUrl(url)
          ? await launchUrl(
              url,
              mode: LaunchMode.externalApplication,
            )
          : print('could_not_launch_this_app');
    }

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
            widget.assigment.url != null && widget.assigment.url!.isNotEmpty
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Reference Document",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          print("Your Url -----> $url");

                          _launchInBrowser(url);
                        },
                        child: const Text("Open File"),
                      ),
                    ],
                  )
                : const Text("No Reference Document"),
          ],
        ),
      ),
    );
  }
}
