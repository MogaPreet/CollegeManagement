import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';

//use riverpod for state management for this code
class AttendancePage extends ConsumerStatefulWidget {
  final List<String> myBranch;
  final String currentYear;
  const AttendancePage({
    super.key,
    required this.myBranch,
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
    final formattedDate = DateTime.now().day.toString() +
        '-' +
        DateTime.now().month.toString() +
        '-' +
        DateTime.now().year.toString() +
        '${widget.currentYear}_${selectedBranch}';

    final excelFileName = formattedDate + '.xlsx';
    final excelFile = File('/storage/emulated/0/Download/$excelFileName');
    List<int>? fileBytes = excel.save();

    if (fileBytes != null) {
      print("workingg");
      excelFile
        ..createSync()
        ..writeAsBytesSync(fileBytes);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 37, 37, 37),
        title: const Text("Attendance"),
        bottom: widget.myBranch.isNotEmpty && widget.myBranch.length > 1
            ? PreferredSize(
                preferredSize: const Size.fromHeight(40),
                child: DropdownButton<String>(
                  borderRadius: BorderRadius.circular(5),
                  dropdownColor: const Color.fromARGB(255, 37, 37, 37),
                  padding: const EdgeInsets.only(left: 24, right: 24),
                  isExpanded: true,
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                  value: selectedBranch.isNotEmpty ? selectedBranch : null,
                  hint: const Text(
                    "Select Branch",
                    style: TextStyle(
                      color: Colors.white,
                    ),
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
          Switch(
            value: switchValues.every((value) => value),
            onChanged: toggleSwitches,
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

            return Column(
              children: [
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: snapshot.data?.docs.length ?? 0,
                  itemBuilder: (context, index) {
                    final DocumentSnapshot documentSnapshot =
                        snapshot.data!.docs[index];
                    return Card(
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
                if (selectedBranch.isNotEmpty)
                  ElevatedButton(
                    onPressed: () async {
                      await generateExcelFile(
                        snapshot.data!.docs,
                        switchValues,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Excel file generated successfully'),
                      ));
                    },
                    child: Text('Download Attandance'),
                  )
              ],
            );
          }),
    );
  }
}
