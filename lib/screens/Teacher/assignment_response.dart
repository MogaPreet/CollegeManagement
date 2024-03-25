import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cms/screens/Teacher/home.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:http/http.dart' as http;

import 'package:path_provider/path_provider.dart';
import 'package:pdf_viewer_plugin/pdf_viewer_plugin.dart';

class AssignmentResponse extends StatefulWidget {
  final String id;
  const AssignmentResponse({super.key, required this.id});

  @override
  State<AssignmentResponse> createState() => _AssignmentResponseState();
}

class _AssignmentResponseState extends State<AssignmentResponse>
    with TickerProviderStateMixin {
  TabController? tabController;
  @override
  void initState() {
    // TODO: implement initState
    tabController = TabController(length: 3, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    CollectionReference assignment = FirebaseFirestore.instance
        .collection('assignments')
        .doc(widget.id)
        .collection('responses');
    Stream<QuerySnapshot<Object?>> query = assignment
        .where(
          "assignmentId",
          isEqualTo: widget.id,
        )
        .where("status",
            isEqualTo: tabController?.index == 0
                ? "in review"
                : tabController?.index == 1
                    ? "accepted"
                    : "rejected")
        .snapshots();

    return Scaffold(
      appBar: AppBar(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(24),
            bottomRight: Radius.circular(24),
          ),
        ),
        backgroundColor: Colors.black12,
        bottom: TabBar(
          controller: tabController,
          onTap: (value) {
            setState(() {});
          },
          tabs: const [
            Tab(
              icon: Icon(Icons.book),
              text: "Review",
            ),
            Tab(
              icon: Icon(Icons.check),
              text: "Accepted",
            ),
            Tab(
              icon: Icon(Icons.thumb_down),
              text: "Rejected",
            ),
          ],
        ),
        title: const Text("Responses"),
        // create tab bar containing 2 tab bar (accepted and rejected)
        leading: BackButton(
          onPressed: () {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) {
              return const TeacherHome();
            }));
          },
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: query,
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
              child: Text("Nothing Here!!"),
            );
          } else {
            return ListView.builder(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                itemCount: len,
                itemBuilder: (context, index) {
                  final DocumentSnapshot response = snapshot.data!.docs[index];
                  return Padding(
                    padding: const EdgeInsets.only(left: 8, right: 8, top: 8),
                    child: Card(
                      child: ListTile(
                        title: Text(response["rollNo"]),
                        trailing: IconButton(
                          onPressed: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return PDFscreen(
                                path: response["url"],
                                rollNo: response["rollNo"],
                                assignmentId: response["assignmentId"],
                                status: response["status"],
                                colref: assignment,
                              );
                            }));
                          },
                          icon: const Icon(Icons.arrow_forward_ios),
                        ),
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
  final String assignmentId;
  final CollectionReference colref;
  final String status;
  const PDFscreen({
    super.key,
    required this.path,
    required this.rollNo,
    required this.assignmentId,
    required this.colref,
    required this.status,
  });

  @override
  State<PDFscreen> createState() => _PDFscreenState();
}

class _PDFscreenState extends State<PDFscreen> {
  String? pdfFlePath;
  bool showPdf = false;
  TextEditingController remarkController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    Future<String> downloadAndSavePdf() async {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/${widget.rollNo}.pdf');
      // if (await file.exists()) {
      //   return file.path;
      // }
      final response = await http.get(Uri.parse(widget.path));
      await file.writeAsBytes(response.bodyBytes);
      return file.path;
    }

    void loadPdf() async {
      pdfFlePath = await downloadAndSavePdf();

      setState(() {
        showPdf = true;
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.rollNo),
        actions: widget.status.toLowerCase() == "accepted"
            ? [const SizedBox.shrink()]
            : [
                IconButton(
                    onPressed: () async {
                      //Add Remark Dialog
                      await showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text(
                                "Add Remark (optional)",
                                style: TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                              content: TextField(
                                controller: remarkController,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Color.fromARGB(255, 37, 37, 37),
                                    ),
                                  ),
                                  hintText: "Remark",
                                ),
                              ),
                              actions: [
                                TextButton(
                                    onPressed: () {
                                      widget.colref
                                          .doc(widget.rollNo)
                                          .update({"status": "rejected"});
                                      if (remarkController.text.isNotEmpty) {
                                        widget.colref.doc(widget.rollNo).update(
                                            {"remark": remarkController.text});
                                      }
                                      Navigator.pushReplacement(context,
                                          MaterialPageRoute(builder: (context) {
                                        return AssignmentResponse(
                                          id: widget.assignmentId,
                                        );
                                      }));
                                    },
                                    style: ButtonStyle(
                                      minimumSize: MaterialStateProperty.all(
                                          const Size(100, 50)),
                                      foregroundColor:
                                          MaterialStateProperty.all(Colors.red),
                                    ),
                                    child: const Text(
                                      "Reject",
                                    ))
                              ],
                            );
                          });
                    },
                    icon: const Icon(Icons.thumb_down)),
                IconButton(
                    onPressed: () async {
                      //Add Remark Dialog
                      await showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text(
                                "Add Remark (optional)",
                                style: TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                              content: TextField(
                                controller: remarkController,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Color.fromARGB(255, 37, 37, 37),
                                    ),
                                  ),
                                  hintText: "Remark",
                                ),
                              ),
                              actions: [
                                TextButton(
                                    onPressed: () {
                                      widget.colref
                                          .doc(widget.rollNo)
                                          .update({"status": "accepted"});
                                      if (remarkController.text.isNotEmpty) {
                                        widget.colref.doc(widget.rollNo).update(
                                            {"remark": remarkController.text});
                                      }
                                      Navigator.pushReplacement(context,
                                          MaterialPageRoute(builder: (context) {
                                        return AssignmentResponse(
                                          id: widget.assignmentId,
                                        );
                                      }));
                                    },
                                    style: ButtonStyle(
                                      minimumSize: MaterialStateProperty.all(
                                          const Size(100, 50)),
                                      foregroundColor:
                                          MaterialStateProperty.all(
                                              Colors.green),
                                    ),
                                    child: const Text(
                                      "Accept",
                                    ))
                              ],
                            );
                          });
                    },
                    icon: const Icon(Icons.check_box))
              ],
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            if (showPdf == false)
              ElevatedButton(
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.black)),
                onPressed: loadPdf,
                child: const Text("See the work"),
              ),
            if (pdfFlePath != null)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: PdfView(path: pdfFlePath ?? "Something went wrong"),
                ),
              )
          ],
        ),
      ),
    );
  }
}

class Options extends StatefulWidget {
  final String status;
  final String assignmentId;
  final CollectionReference colref;
  const Options({
    super.key,
    required this.status,
    required this.assignmentId,
    required this.colref,
  });

  @override
  State<Options> createState() => OoptionsState();
}

class OoptionsState extends State<Options> {
  @override
  Widget build(BuildContext context) {
    return const AlertDialog();
  }
}
