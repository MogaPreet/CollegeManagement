import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf_viewer_plugin/pdf_viewer_plugin.dart';

class AssignmentResponse extends StatefulWidget {
  final String id;
  const AssignmentResponse({super.key, required this.id});

  @override
  State<AssignmentResponse> createState() => _AssignmentResponseState();
}

class _AssignmentResponseState extends State<AssignmentResponse> {
  @override
  Widget build(BuildContext context) {
    CollectionReference assignment = FirebaseFirestore.instance
        .collection('assignments')
        .doc(widget.id)
        .collection('responses');

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: const BackButton(),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            assignment.where("assignmentId", isEqualTo: widget.id).snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Text('Something went wrong');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CupertinoActivityIndicator());
          }
          var len = snapshot.data?.docs.length ?? 0;
          if (len < 1) {
            return const Center(
              child: Text("No one has Submitted the assignments"),
            );
          } else {
            return ListView.builder(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                itemCount: len,
                itemBuilder: (context, index) {
                  final DocumentSnapshot response = snapshot.data!.docs[index];
                  return Card(
                    child: ListTile(
                      title: Text(response["rollNo"]),
                      trailing: IconButton(
                        onPressed: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return PDFscreen(
                              path: response["url"],
                              rollNo: response["rollNo"],
                            );
                          }));
                        },
                        icon: const Icon(Icons.remove_red_eye),
                      ),
                    ),
                  );
                });
          }
        },
      ),
    );
  }
}

class PDFscreen extends StatefulWidget {
  final String path;
  final String rollNo;
  const PDFscreen({super.key, required this.path, required this.rollNo});

  @override
  State<PDFscreen> createState() => _PDFscreenState();
}

class _PDFscreenState extends State<PDFscreen> {
  String? pdfFlePath;

  @override
  Widget build(BuildContext context) {
    Future<String> downloadAndSavePdf() async {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/${widget.rollNo}.pdf');
      if (await file.exists()) {
        return file.path;
      }
      final response = await http.get(Uri.parse(widget.path));
      await file.writeAsBytes(response.bodyBytes);
      return file.path;
    }

    void loadPdf() async {
      pdfFlePath = await downloadAndSavePdf();
      setState(() {});
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Roll No"),
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            ElevatedButton(
              child: Text("See the work"),
              onPressed: loadPdf,
            ),
            if (pdfFlePath != null)
              Expanded(
                child: Container(
                  child: PdfView(path: pdfFlePath!),
                ),
              )
            else
              Text("Student Might Have Post other than PDF file"),
          ],
        ),
      ),
    );
  }
}
