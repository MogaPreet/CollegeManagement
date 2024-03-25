import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cms/models/attendance.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';

//use riverpod for state management for this code
class AttendancePage extends ConsumerStatefulWidget {
  final List<String> myBranch;
  final String subject;
  final String currentYear;
  const AttendancePage({
    super.key,
    required this.myBranch,
    required this.subject,
    required this.currentYear,
  });

  @override
  ConsumerState<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends ConsumerState<AttendancePage> {
  CollectionReference students =
      FirebaseFirestore.instance.collection('students');

  List<bool> switchValues = List.generate(5, (index) => false);

  void toggleSwitches(bool value) {
    setState(() {
      for (int i = 0; i < switchValues.length; i++) {
        switchValues[i] = value;
      }
    });
  }

  String selectedBranch = "";
  Future<void> generateExcelFile(
      List<DocumentSnapshot> students, List<bool> switchValues) async {
    final excel = Excel.createExcel();

    final sheet = excel['Students'];

    // Headers
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0)).value =
        'Roll No';
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 0)).value =
        'First Name';
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: 0)).value =
        'Last Name';
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: 0)).value =
        'Present/Absent';

    // Student data
    for (int i = 0; i < students.length; i++) {
      final DocumentSnapshot student = students[i];
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: i + 1))
          .value = student['rollNo'].toString();
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: i + 1))
          .value = student['firstName'];
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: i + 1))
          .value = student['lastName'];
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: i + 1))
          .value = switchValues[i] ? 'Present' : 'Absent';
    }

    // Save Excel file
    final documentsDirectory = await getApplicationDocumentsDirectory();
    print(documentsDirectory.path);
    final formattedDate =
        '${DateTime.now().day}-${DateTime.now().month}-${DateTime.now().year}${widget.currentYear}_${selectedBranch}';

    final excelFileName = formattedDate + '.xlsx';
    final excelFile = File('/storage/emulated/0/Download/$excelFileName');
    List<int>? fileBytes = excel.save();

    if (fileBytes != null) {
      print("workingg");
      excelFile
        ..createSync()
        ..writeAsBytesSync(fileBytes);
      await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Success'),
            content: Text('File saved to ${excelFile.path}'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('OK'),
              )
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Attendance"),
        backgroundColor: Colors.black12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(24),
            bottomRight: Radius.circular(24),
          ),
        ),
        bottom: widget.myBranch.isNotEmpty && widget.myBranch.length > 1
            ? PreferredSize(
                preferredSize: const Size.fromHeight(60),
                child: DropdownButton<String>(
                  borderRadius: BorderRadius.circular(5),
                  padding: const EdgeInsets.only(left: 24, right: 24),
                  isExpanded: true,
                  underline: SizedBox(),
                  value: selectedBranch.isNotEmpty ? selectedBranch : null,
                  hint: const Text(
                    "Select Branch",
                    style: TextStyle(),
                  ),
                  items: List.generate(
                      widget.myBranch.length,
                      (index) => DropdownMenuItem(
                            value: widget.myBranch[index],
                            child: Text(widget.myBranch[index]),
                          )).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedBranch = value ?? "";
                    });
                  },
                ),
              )
            : null,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Switch(
              value: switchValues.every((value) => value),
              onChanged: toggleSwitches,
            ),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream: students
              .where("branch",
                  isEqualTo: widget.myBranch.length > 1
                      ? selectedBranch.isNotEmpty
                          ? selectedBranch
                          : widget.myBranch
                      : widget.myBranch.first)
              .where("currentYear", isEqualTo: widget.currentYear)
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return const Text('Something went wrong');
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Column(
                children: [Center(child: CircularProgressIndicator())],
              );
            }

            return Padding(
              padding: const EdgeInsets.only(
                left: 20,
                right: 20,
                top: 24,
              ),
              child: Column(
                children: [
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: snapshot.data?.docs.length ?? 0,
                    itemBuilder: (context, index) {
                      final DocumentSnapshot documentSnapshot =
                          snapshot.data!.docs[index];
                      return Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        color: Colors.blue.shade50,
                        child: ListTile(
                          title: Text(documentSnapshot["rollNo"]),
                          subtitle: Text(documentSnapshot["firstName"]),
                          trailing: Switch(
                            value: switchValues[index],
                            onChanged: (value) {
                              setState(() {
                                switchValues[index] = value;
                              });
                            },
                          ),
                        ),
                      );
                    },
                  ),
                  Spacer(),
                  if (selectedBranch.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: SizedBox(
                        width: double.infinity,
                        child: Consumer(builder: (context, refX, child) {
                          return ElevatedButton(
                            style: ButtonStyle(
                              foregroundColor: MaterialStateProperty.all(
                                Colors.black,
                              ),
                              backgroundColor: MaterialStateProperty.all(
                                  Colors.green.shade50),
                              shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            onPressed: () async {
                              try {
                                await FirebaseFirestore.instance
                                    .collection('attendance')
                                    .add({
                                  'branch': selectedBranch,
                                  'year': widget.currentYear,
                                  'subject': widget.subject,
                                  'date': Timestamp.now(),
                                  'presentStudents': switchValues
                                      .asMap()
                                      .entries
                                      .where((element) => element.value)
                                      .map((e) => snapshot.data!.docs[e.key]
                                          .get('uid')
                                          .toString())
                                      .toList(),
                                });
                                await generateExcelFile(
                                  snapshot.data!.docs,
                                  switchValues,
                                );
                              } catch (e) {
                                // ignore: use_build_context_synchronously
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: const Text('Error'),
                                        content: Text(e.toString()),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: const Text('OK'),
                                          )
                                        ],
                                      );
                                    });
                              } finally {}
                            },
                            child: Text('Download Attandance'),
                          );
                        }),
                      ),
                    )
                ],
              ),
            );
          }),
    );
  }
}
