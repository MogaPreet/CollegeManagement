import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cms/models/assignment.dart';
import 'package:cms/models/user.dart';
import 'package:cms/screens/Student/studentHome.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_file_view/flutter_file_view.dart';
import 'package:path/path.dart' as p;
import 'package:url_launcher/link.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:uuid/uuid.dart';

import '../Teacher/assignment.dart';

class ShowAssignments extends StatefulWidget {
  final AssignMentModel assigment;
  final String userId;
  const ShowAssignments(
      {super.key, required this.assigment, required this.userId});

  @override
  State<ShowAssignments> createState() => _ShowAssignmentsState();
}

class _ShowAssignmentsState extends State<ShowAssignments> {
  UploadTask? task;
  File? file;
  String? url1;
  bool isLoading = false;
  final assignmentTitleController = TextEditingController();
  Future selectFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result == null) return;
    final path = result.files.single.path!;

    setState(() => file = File(path));
  }

  Future uploadFile() async {
    if (file == null) return;

    final destination = 'files/${assignmentTitleController.text}';

    task = FirebaseApi.uploadFile(destination, file!);

    setState(() {});

    if (task == null) return;

    final snapshot = await task!.whenComplete(() {
      showDialog(
          context: context,
          builder: (context) {
            return Material(child: buildUploadStatus(task!));
          });
    });
    final urlDownload = await snapshot.ref.getDownloadURL();
    setState(() {
      url1 = urlDownload;
    });
  }

  Widget buildUploadStatus(UploadTask task) => StreamBuilder<TaskSnapshot>(
        stream: task.snapshotEvents,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final snap = snapshot.data!;
            final progress = snap.bytesTransferred / snap.totalBytes;
            final percentage = (progress * 100).toStringAsFixed(2);

            return Center(
              child: Text(
                '$percentage %',
                style:
                    const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
              ),
            );
          } else {
            return Container();
          }
        },
      );
  Widget assignmentImage() {
    return Center(
      child: Stack(
        children: <Widget>[
          InkWell(
            onTap: () async {
              setState(() {
                file = null;
              });
            },
            child: Container(
              width: double.infinity,
              height: 200.0,
              decoration: BoxDecoration(
                  border: Border.all(color: Color.fromARGB(255, 37, 37, 37))),
              child: file != null &&
                          file!.path.isNotEmpty &&
                          p.extension(file!.path).contains('.jpeg') ||
                      p.extension(file!.path).contains('.png') ||
                      p.extension(file!.path).contains('.jpg')
                  ? Image.file(
                      File(file!.path),
                      fit: BoxFit.cover,
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.file_copy_outlined),
                        Text(p.basename(file!.path))
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectFileButton = Material(
      elevation: 5,
      borderRadius: BorderRadius.circular(5),
      color: const Color.fromARGB(255, 37, 37, 37),
      child: MaterialButton(
        padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
        minWidth: MediaQuery.of(context).size.width,
        onPressed: () {
          selectFile();
        },
        child: const Text(
          "Select file",
          style: TextStyle(fontSize: 15.0, color: Colors.white),
        ),
      ),
    );
    final Uri url = Uri.parse(widget.assigment.url ?? "");
    Future<void> _launchInBrowser(Uri url) async {
      await canLaunchUrl(url)
          ? await launchUrl(
              url,
              mode: LaunchMode.externalApplication,
            )
          : print('could_not_launch_this_app');
    }

    void addAssignment() async {
      String assignmentId = widget.assigment.assignmentId ?? "";

      if (file != null && file!.path.isNotEmpty) {
        setState(() {
          isLoading = true;
        });
        await uploadFile();

        try {
          // final id = uuid.v4();
          AssignmentResponseModel assignment = AssignmentResponseModel();
          assignment.id = widget.userId;
          assignment.assignedDate = widget.assigment.getAssignDate!.toDate();
          assignment.lastDate = widget.assigment.getLastDate!.toDate();
          assignment.url = url1;
          assignment.status = "in review";
          assignment.assignmentId = assignmentId;
          print(widget.userId);
          CollectionReference students =
              FirebaseFirestore.instance.collection("students");
          CollectionReference<Map<String, dynamic>> dbRef =
              students.doc(widget.userId).collection("assignments");
          await dbRef.add(assignment.toMap());

          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(
                  "Successfully Uploaded ${assignmentTitleController.text}")));
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const StudentHomePage()),
              (route) => false);
        } catch (error) {
          print('error occured ${error}');
        } finally {
          setState(() {
            isLoading = false;
          });
        }
      }
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
            selectFileButton,
            const SizedBox(
              height: 20,
            ),
            if (file != null && file!.path.isNotEmpty)
              Column(
                children: [
                  InkWell(
                    onTap: () {
                      setState(() {
                        file = null;
                      });
                    },
                    child: const Icon(Icons.cancel),
                  ),
                  assignmentImage(),
                ],
              ),
            MaterialButton(
              minWidth: double.infinity,
              color: const Color.fromARGB(255, 37, 37, 37),
              textColor: Colors.white,
              onPressed: () async {
                addAssignment();
              },
              child: isLoading
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: const <Widget>[
                        SizedBox(
                          height: 10,
                          width: 10,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                          ),
                        ),
                        Text("Adding assingment.....")
                      ],
                    )
                  : const Text(
                      "Add Assignment",
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
