import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cms/models/assignment.dart';
import 'package:cms/models/user.dart';
import 'package:cms/screens/Student/widgets/progressIndicator.dart';
import 'package:cms/screens/Teacher/home.dart';
import 'package:cms/screens/teacher_signup.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

final getUrl = StateProvider<String?>((ref) {
  return "";
});
final selectBranchForAssignment = StateProvider<String>((ref) {
  return "";
});

class AssignmentTeacherPage extends ConsumerStatefulWidget {
  final TeacherModel teacher;
  final String? subject;

  final String year;
  const AssignmentTeacherPage(
      {super.key,
      required this.teacher,
      required this.subject,
      required this.year});

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
  DateTime? currentDate;
  bool isLoading = false;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: currentDate ?? DateTime.now(),
        firstDate: DateTime.now(),
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
      showDialog(
          context: context,
          builder: (context) {
            return Material(child: buildUploadStatus(task!));
          });
    });
    final urlDownload = await snapshot.ref.getDownloadURL();
    setState(() {
      url = urlDownload;
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

  Widget branchSelection() {
    return DecoratedBox(
      decoration: BoxDecoration(
          color: const Color.fromARGB(255, 37, 37, 37),
          borderRadius: BorderRadius.circular(12)),
      child: DropdownButton(
        underline: const SizedBox(),

        padding: const EdgeInsets.only(
          left: 10,
          right: 10,
        ),
        // Initial Value
        value: ref.read(selectBranchForAssignment).isNotEmpty
            ? ref.read(selectBranchForAssignment)
            : widget.teacher.branch![0],
        disabledHint: const Text("Select Branch"),
        style: const TextStyle(color: Colors.white, fontSize: 15),

        borderRadius: BorderRadius.circular(12),

        isExpanded: true,
        dropdownColor: const Color.fromARGB(255, 37, 37, 37),
        // Down Arrow Icon

        icon: const Icon(
          Icons.keyboard_arrow_down,
          color: Colors.white,
        ),

        // Array list of items
        items: widget.teacher.branch!.map((String branch) {
          return DropdownMenuItem(
            value: branch,
            child: Text(branch),
          );
        }).toList(),
        // After selecting the desired option,it will

        onChanged: (String? newValue) {
          setState(() {
            ref
                .watch(selectBranchForAssignment.notifier)
                .update((state) => newValue!);
          });
        },
        hint: const Text("select college"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateSelectionButton = Material(
      elevation: 3,
      borderRadius: BorderRadius.circular(12),
      color: const Color.fromARGB(255, 37, 37, 37),
      child: MaterialButton(
        minWidth: MediaQuery.of(context).size.width,
        onPressed: () {
          _selectDate(context);
        },
        child: Text(
          currentDate != null
              ? DateFormat('MMM d,yyyy').format(currentDate ?? DateTime.now())
              : "Select Last Date",
          style: const TextStyle(fontSize: 15.0, color: Colors.white),
        ),
      ),
    );
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
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(12.0),
        ),
        prefixIcon: const Icon(
          Icons.event_available_outlined,
          color: Color.fromARGB(255, 37, 37, 37),
        ),
        hintText: "Title",
      ),
    );
    final assignmentDesc = TextFormField(
      controller: assignDescController,
      minLines: 1,
      maxLines: 10,
      validator: (value) {
        if (value != null && value.isEmpty) {
          return "Assignment Descreiption is Required";
        } else {
          return null;
        }
      },
      onSaved: (value) {
        assignDescController.text = value ?? "";
      },
      keyboardType: TextInputType.multiline,
      decoration: InputDecoration(
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(12.0),
        ),
        prefixIcon: const Icon(
          Icons.description_outlined,
          color: Color.fromARGB(255, 37, 37, 37),
        ),
        hintText: "Description",
      ),
    );
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
          "Select file",
          style: TextStyle(fontSize: 15.0, color: Colors.white),
        ),
      ),
    );

    void addAssignment() async {
      var uuid = const Uuid();
      String assignmentId = uuid.v4();
      String currentBranch = await ref.watch(selectBranchForAssignment);
      String branchLogic() {
        if (currentBranch.isNotEmpty) {
          return currentBranch;
        } else {
          return widget.teacher.branch![0];
        }
      }

      final isValid = _formKey.currentState!.validate();
      if (isValid && currentDate != null) {
        setState(() {
          isLoading = true;
        });
        await uploadFile();
        _formKey.currentState!.save();
        try {
          // final id = uuid.v4();
          AssignMentModel assignment = AssignMentModel();
          assignment.id = widget.teacher.uid;
          assignment.desc = assignDescController.text;
          assignment.title = assignmentTitleController.text;
          assignment.assignedBy = widget.teacher.firstName;
          assignment.url = url;
          assignment.subject = widget.subject;
          assignment.assignedDate = DateTime.now();
          assignment.lastDate = currentDate;
          assignment.toBranch = branchLogic();
          assignment.year = widget.year;
          assignment.assignmentId = assignmentId;

          await FirebaseFirestore.instance
              .collection('assignments')
              .doc(assignmentId)
              .set(assignment.toMap());

          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(
                  "Successfully Added ${assignmentTitleController.text}")));
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const TeacherHome()),
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
        centerTitle: true,
        titleSpacing: 0,
        toolbarHeight: 100,
        backgroundColor: Colors.black12,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(24),
            bottomRight: Radius.circular(24),
          ),
        ),
        title: Column(
          children: [
            const Text("Assignment"),
            Text(
              widget.subject ?? "",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
      bottomSheet: MaterialButton(
        padding: const EdgeInsets.symmetric(
          vertical: 15.0,
        ),
        minWidth: double.infinity,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
          topRight: Radius.circular(24),
          topLeft: Radius.circular(24),
        )),
        color: const Color.fromARGB(255, 37, 37, 37),
        textColor: Colors.white,
        onPressed: () async {
          addAssignment();
        },
        child: isLoading
            ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
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
                  Text("Adding assingment.....")
                ],
              )
            : const Text(
                "Add Assignment",
              ),
      ),
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
                shrinkWrap: true,
                physics: BouncingScrollPhysics(),
                children: <Widget>[
                  const SizedBox(
                    height: 15,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      assignTitle,
                      const SizedBox(
                        height: 20,
                      ),
                      assignmentDesc,
                      const SizedBox(
                        height: 20,
                      ),
                      dateSelectionButton,
                      const SizedBox(
                        height: 20,
                      ),
                      widget.teacher.branch!.length == 1
                          ? Text(
                              widget.teacher.branch!.map((e) => e).toString())
                          : branchSelection(),
                      const SizedBox(
                        height: 20,
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
                ],
              )),
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
