import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cms/screens/Teacher/home.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:http/http.dart' as http;

import 'package:path_provider/path_provider.dart';

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
  String? pdfFilePath;
  bool isLoading = false;
  int totalPages = 0;
  int currentPage = 0;
  bool pdfReady = false;
  TextEditingController remarkController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
  }

  Future<File> downloadPDF() async {
    setState(() {
      isLoading = true;
    });
    
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/${widget.rollNo}.pdf');
    
    try {
      final response = await http.get(Uri.parse(widget.path));
      final file = File('${directory.path}/${widget.rollNo}.pdf');
      await file.writeAsBytes(response.bodyBytes);
      setState(() {
        pdfFilePath = file.path;
        isLoading = false;
        pdfReady = true;
      });
      return file;
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to download PDF: $e')),
      );
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
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
                              )
                            )
                          ],
                        );
                      }
                    );
                  },
                  icon: const Icon(Icons.thumb_down)
                ),
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
                              )
                            )
                          ],
                        );
                      }
                    );
                  },
                  icon: const Icon(Icons.check_box)
                )
              ],
      ),
      body: Column(
        children: <Widget>[
          if (!pdfReady)
            Expanded(
              child: Center(
                child: isLoading
                    ? const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Downloading PDF...'),
                        ],
                      )
                    : ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(Colors.black),
                        ),
                        onPressed: downloadPDF,
                        child: const Text("Download and View PDF"),
                      ),
              ),
            ),
          if (pdfReady && pdfFilePath != null)
            Expanded(
              child: Stack(
                children: [
                  PDFView(
                    filePath: pdfFilePath!,
                    enableSwipe: true,
                    swipeHorizontal: true,
                    autoSpacing: true,
                    pageFling: true,
                    pageSnap: true,
                    defaultPage: currentPage,
                    fitPolicy: FitPolicy.BOTH,
                    preventLinkNavigation: false,
                    onRender: (_pages) {
                      setState(() {
                        totalPages = _pages!;
                        pdfReady = true;
                      });
                    },
                    onError: (error) {
                      setState(() {
                        pdfReady = false;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $error')),
                      );
                    },
                    onPageError: (page, error) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error on page $page: $error')),
                      );
                    },
                    onViewCreated: (PDFViewController pdfViewController) {
                      // Save the controller for later use
                    },
                    onPageChanged: (int? page, int? total) {
                      setState(() {
                        currentPage = page!;
                      });
                    },
                  ),
                  // Page indicator at the bottom of the PDF
                  pdfReady ? Positioned(
                    bottom: 20,
                    left: 0,
                    right: 0,
                    child: Container(
                      alignment: Alignment.center,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: Colors.black54,
                        ),
                        child: Text(
                          'Page ${currentPage + 1} of $totalPages',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ) : Container(),
                ],
              ),
            ),
        ],
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