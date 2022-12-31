import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cms/models/assignment.dart';
import 'package:cms/models/user.dart';
import 'package:cms/screens/Teacher/home.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';

final getUrl = StateProvider<String?>((ref) {
  return "";
});

class AssignmentTeacherPage extends ConsumerStatefulWidget {
  final TeacherModel teacher;
  final String subject;
  const AssignmentTeacherPage(
      {super.key, required this.teacher, required this.subject});

  @override
  ConsumerState<AssignmentTeacherPage> createState() =>
      _AssignmentTeacherPageState();
}

class _AssignmentTeacherPageState extends ConsumerState<AssignmentTeacherPage> {
  @override
  final _formKey = GlobalKey<FormState>();
  String? url;
  UploadTask? task;
  File? file;
  final assignmentTitleController = TextEditingController();
  final assignDescController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  DateTime currentDate = DateTime.now();
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: currentDate,
        firstDate: DateTime(2015),
        lastDate: DateTime(2050));
    if (pickedDate != null && pickedDate != currentDate) {
      setState(() {
        currentDate = pickedDate;
      });
    }
  }

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
      print("Successfully uploaded");
    });
    final urlDownload = await snapshot.ref.getDownloadURL();
    setState(() {
      url = urlDownload;
    });
    print('Download-Link: $urlDownload');
  }

  Widget buildUploadStatus(UploadTask task) => StreamBuilder<TaskSnapshot>(
        stream: task.snapshotEvents,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final snap = snapshot.data!;
            final progress = snap.bytesTransferred / snap.totalBytes;
            final percentage = (progress * 100).toStringAsFixed(2);

            return Text(
              '$percentage %',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            );
          } else {
            return Container();
          }
        },
      );
  @override
  Widget build(BuildContext context) {
    final assignTitle = TextFormField(
      controller: assignmentTitleController,
      validator: (value) {
        if (value != null && value.isEmpty) {
          return "Assignment Name is Required";
        } else {
          return null;
        }
      },
      onSaved: (value) {
        assignmentTitleController.text = value!;
      },
      decoration: InputDecoration(
        border: const OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.black,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(width: 2, color: Colors.black),
          borderRadius: BorderRadius.circular(5.0),
        ),
        prefixIcon: const Icon(
          Icons.event_available_outlined,
          color: Colors.black,
        ),
        hintText: "Assignment title",
      ),
    );
    final assignmentDesc = TextFormField(
      controller: assignDescController,
      minLines: 1,
      maxLines: 10,
      onSaved: (value) {
        assignDescController.text = value ?? "";
      },
      keyboardType: TextInputType.multiline,
      decoration: InputDecoration(
        border: const OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.black,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(width: 2, color: Colors.black),
          borderRadius: BorderRadius.circular(5.0),
        ),
        prefixIcon: const Icon(
          Icons.description_outlined,
          color: Colors.black,
        ),
        hintText: "Assignment Description",
      ),
    );
    final selectFileButton = TextButton(
      onPressed: () {
        selectFile();
      },
      child: const Text("Select File "),
    );
    void addAssignment() async {
      final isValid = _formKey.currentState!.validate();
      var date = DateTime.now().toString();

      var dateparse = DateTime.parse(date);
      await uploadFile();
      if (isValid) {
        _formKey.currentState!.save();
        try {
          // final id = uuid.v4();
          AssignMentModel assignment = AssignMentModel();
          assignment.id = 1;
          assignment.desc = assignDescController.text;
          assignment.title = assignmentTitleController.text;
          assignment.assignedBy = widget.teacher.firstName;
          assignment.url = url;
          assignment.subject = widget.subject;
          assignment.assignedDate = DateTime.now();
          assignment.lastDate = currentDate;
          assignment.toBranch = widget.teacher.branch;

          await FirebaseFirestore.instance
              .collection('assignemnts')
              .doc()
              .set(assignment.toMap());

          // ignore: use_build_context_synchronously
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const TeacherHome()),
              (route) => false);
        } catch (error) {
          print('error occured ${error}');
        } finally {
          // setState(() {
          //   _isLoading = false;
          // });
        }
      }
    }

    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
          child: NotificationListener<OverscrollIndicatorNotification>(
            onNotification: ((overscroll) {
              overscroll.disallowIndicator();
              return true;
            }),
            child: Form(
                key: _formKey,
                child: ListView(
                  children: <Widget>[
                    const SizedBox(
                      height: 15,
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          "Add Notice",
                        ),
                        assignTitle,
                        const SizedBox(
                          height: 20,
                        ),
                        assignmentDesc,
                        const SizedBox(
                          height: 20,
                        ),
                        TextButton(
                            onPressed: () {
                              _selectDate(context);
                            },
                            child:
                                const Text("Select Last Date for assignment")),
                        const SizedBox(
                          height: 20,
                        ),
                        selectFileButton,
                        const SizedBox(
                          height: 20,
                        ),
                        TextButton(
                            onPressed: () {
                              addAssignment();
                            },
                            child: const Text("Add Assignment"))
                      ],
                    )
                  ],
                )),
          ),
        ),
      ),
    );
  }
}

class FirebaseApi {
  static UploadTask? uploadFile(String destination, File file) {
    try {
      final ref = FirebaseStorage.instance.ref(destination);

      return ref.putFile(file);
    } on FirebaseException catch (e) {
      return null;
    }
  }

  static UploadTask? uploadBytes(String destination, Uint8List data) {
    try {
      final ref = FirebaseStorage.instance.ref(destination);

      return ref.putData(data);
    } on FirebaseException catch (e) {
      return null;
    }
  }
}
