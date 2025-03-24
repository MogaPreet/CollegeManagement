import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cms/models/attendance.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

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

  List<bool> switchValues = List.generate(85, (index) => false);

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
    try {
      // Create a new Excel document
      final excel = Excel.createExcel();
      final sheet = excel['Students'];

      // Define header styles
      final headerStyle = CellStyle(
        bold: true,
    
        horizontalAlign: HorizontalAlign.Center,
      );

      // Add headers with styling
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0))
        ..value = TextCellValue('Roll No')
        ..cellStyle = headerStyle;

      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 0))
        ..value = TextCellValue('First Name')
        ..cellStyle = headerStyle;

      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: 0))
        ..value = TextCellValue('Last Name')
        ..cellStyle = headerStyle;

      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: 0))
        ..value = TextCellValue('Present/Absent')
        ..cellStyle = headerStyle;

      // Define cell styles for present/absent
      final presentStyle = CellStyle(
      
        horizontalAlign: HorizontalAlign.Center,
      );

      final absentStyle = CellStyle(
     
        horizontalAlign: HorizontalAlign.Center,
      );

      // Add student data
      for (int i = 0; i < students.length && i < switchValues.length; i++) {
        final DocumentSnapshot student = students[i];
        final data = student.data() as Map<String, dynamic>?;

        if (data == null) continue;

        // Add roll number
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: i + 1))
          ..value = TextCellValue(data['rollNo']?.toString() ?? 'N/A');

        // Add first name
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: i + 1))
          ..value = TextCellValue(data['firstName']?.toString() ?? 'N/A');

        // Add last name
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: i + 1))
          ..value = TextCellValue(data['lastName']?.toString() ?? '');

        // Add attendance status with appropriate styling
        final isPresent = i < switchValues.length && switchValues[i];
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: i + 1))
          ..value = TextCellValue(isPresent ? 'Present' : 'Absent')
          ..cellStyle = isPresent ? presentStyle : absentStyle;
      }

      // Add a summary row
      final totalRow = students.length + 2;
      final presentCount = switchValues.where((value) => value).length;

      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: totalRow))
        ..value = TextCellValue('Summary')
        ..cellStyle = CellStyle(bold: true);

      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: totalRow))
        ..value = TextCellValue('Total: ${students.length}');

      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: totalRow))
        ..value = TextCellValue('Present: $presentCount');

      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: totalRow))
        ..value = TextCellValue('Absent: ${students.length - presentCount}');

      // Set column widths for better readability
      sheet.setColumnWidth(0, 15);
      sheet.setColumnWidth(1, 20);
      sheet.setColumnWidth(2, 20);
      sheet.setColumnWidth(3, 20);

      // Create file name with proper formatting
      final now = DateTime.now();
      final formattedDate = '${now.day}-${now.month}-${now.year}';
      final branch = selectedBranch.isNotEmpty ? selectedBranch : widget.myBranch.first;
      final excelFileName = 'Attendance_${widget.subject}_${widget.currentYear}_${branch}_${formattedDate}.xlsx';

      // Check if permission is granted
      var status = await Permission.storage.status;
      if (!status.isGranted) {
        await Permission.storage.request();
        status = await Permission.storage.status;
        if (!status.isGranted) {
          throw Exception("Storage permission not granted");
        }
      }

      try {
        // Try to save to Downloads folder
        final excelFile = File('/storage/emulated/0/Download/$excelFileName');
        final bytes = excel.encode();

        if (bytes != null) {
          await excelFile.writeAsBytes(bytes);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('File saved to Downloads/$excelFileName'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 5),
                action: SnackBarAction(
                  label: 'OK',
                  textColor: Colors.white,
                  onPressed: () {},
                ),
              ),
            );
          }
          return;
        } else {
          throw Exception("Failed to encode Excel file");
        }
      } catch (e) {
        print("Error saving to Downloads: $e");

        // Fallback: save to app documents directory
        try {
          final directory = await getApplicationDocumentsDirectory();
          final excelFile = File('${directory.path}/$excelFileName');
          final bytes = excel.encode();

          if (bytes != null) {
            await excelFile.writeAsBytes(bytes);

            if (mounted) {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Excel File Created'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('File saved to:'),
                      SizedBox(height: 8),
                      Text(
                        excelFile.path,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Note: The file is saved in the app\'s private directory since access to Downloads folder was denied.',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            }
          } else {
            throw Exception("Failed to encode Excel file");
          }
        } catch (innerError) {
          print("Error in fallback save: $innerError");
          throw innerError;
        }
      }
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: Text('Failed to create Excel file: ${e.toString()}'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
      print("Excel generation error: $e");
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
                            backgroundColor:
                                MaterialStateProperty.all(Colors.green.shade50),
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
