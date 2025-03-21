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
  final String rollNo;
  final String userId;
  const ShowAssignments(
      {super.key,
      required this.assigment,
      required this.rollNo,
      required this.userId});

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
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result == null) return;
    final path = result.files.single.path!;

    setState(() => file = File(path));
  }

  Future uploadFile() async {
    if (file == null) return;
    Uuid randId = const Uuid();
    final destination = 'files/assignments/${randId.v4()}';

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
                  border:
                      Border.all(color: const Color.fromARGB(255, 37, 37, 37))),
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
      elevation: 3,
      borderRadius: BorderRadius.circular(12),
      color: const Color.fromARGB(255, 37, 37, 37),
      child: MaterialButton(
        minWidth: MediaQuery.of(context).size.width,
        onPressed: () {
          selectFile();
        },
        child: const Text(
          "Upload file",
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
          assignment.submittedDate = DateTime.now();
          assignment.url = url1;
          assignment.status = "in review";
          assignment.assignmentId = assignmentId;
          assignment.rollNo = widget.rollNo;
          print(widget.userId);
          CollectionReference students =
              FirebaseFirestore.instance.collection("assignments");
          CollectionReference<Map<String, dynamic>> dbRef =
              students.doc(widget.userId).collection("responses");
          await students
              .doc(assignmentId)
              .collection("responses")
              .doc(widget.rollNo)
              .set(assignment.toMap());

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
      bottomSheet: MaterialButton(
        minWidth: MediaQuery.of(context).size.width,
        height: 50,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        color: const Color.fromARGB(255, 37, 37, 37),
        textColor: Colors.white,
        onPressed: () async {
          addAssignment();
        },
        child: isLoading
            ? const Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    height: 10,
                    width: 10,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text("Please Wait..")
                ],
              )
            : const Text(
                "Submit",
              ),
      ),
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
        title: const Text("Assignment Details"),
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
            if (widget.assigment.url != null &&
                widget.assigment.url!.isNotEmpty)
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(
                    double.infinity,
                    50,
                  ),
                  foregroundColor: Colors.white,
                  backgroundColor: const Color.fromARGB(255, 37, 37, 37),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                onPressed: () {
                  print("Your Url -----> $url");

                  _launchInBrowser(url);
                },
                child: const Text("Reference Document"),
              ),
            SizedBox(
              height: 10,
            ),
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
          ],
        ),
      ),
    );
  }
}
