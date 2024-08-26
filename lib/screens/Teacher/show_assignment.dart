import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cms/screens/Teacher/assignment_response.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/assignment.dart';

class ShowAssignment extends StatefulWidget {
  final String userId;
  const ShowAssignment({super.key, required this.userId});

  @override
  State<ShowAssignment> createState() => _ShowAssignmentState();
}

class _ShowAssignmentState extends State<ShowAssignment> {
  DateTime? tempDate;
  TextStyle subtitles = const TextStyle(
    fontWeight: FontWeight.w500,
    color: Colors.grey,
    fontSize: 12,
  );
  @override
  Widget build(BuildContext context) {
    TextEditingController desc = TextEditingController();
    final _formKey = GlobalKey<FormState>();
    CollectionReference assignment =
        FirebaseFirestore.instance.collection('assignments');
    Widget appButton(
      Color? color,
      void Function() action,
      IconData icon,
      Text label,
      Color? fColor,
    ) {
      return TextButton.icon(
        onPressed: action,
        icon: Icon(
          icon,
          size: 18,
        ),
        label: label,
        style: ButtonStyle(
          padding: MaterialStateProperty.all(const EdgeInsets.all(8)),
          textStyle: MaterialStateProperty.all(const TextStyle(
            fontSize: 16,
          )),
          backgroundColor: MaterialStateProperty.all(color),
          foregroundColor: MaterialStateProperty.all(fColor ?? Colors.white),
        ),
      );
    }

    DateTime? currentDate;

    bool showLoading = false;
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
          stream: assignment.where("id", isEqualTo: widget.userId).snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return const Text('Someing went wrong');
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CupertinoActivityIndicator());
            }

            var len = snapshot.data?.docs.length ?? 0;

            if (len < 1) {
              return const Center(
                child: Text("No assignments"),
              );
            } else {
              return ListView.builder(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  itemCount: len,
                  itemBuilder: (context, index) {
                    final DocumentSnapshot documentSnapshot =
                        snapshot.data!.docs[index];
                    Timestamp date = documentSnapshot["lastDate"] as Timestamp;
                    DateTime d = date.toDate();
                    Future<void> _selectDate(BuildContext context) async {
                      final DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: d,
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2050));
                      if (pickedDate != null && pickedDate != currentDate) {
                        setState(() {
                          currentDate = pickedDate;
                        });
                      }
                    }

                    final dateSelectionButton = Material(
                      elevation: 5,
                      borderRadius: BorderRadius.circular(5),
                      color: const Color.fromARGB(255, 37, 37, 37),
                      child: MaterialButton(
                        padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
                        minWidth: MediaQuery.of(context).size.width,
                        onPressed: () {
                          _selectDate(context);
                        },
                        child: Text(
                          currentDate != null
                              ? DateFormat('MMM d,yyyy')
                                  .format(currentDate ?? DateTime.now())
                              : "Select Last Date",
                          style: const TextStyle(
                              fontSize: 15.0, color: Colors.white),
                        ),
                      ),
                    );
                    return Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Card(
                        child: ExpansionTile(
                          childrenPadding:
                              const EdgeInsets.only(top: 6, bottom: 6.0),
                          textColor: const Color.fromARGB(255, 37, 37, 37),
                          title: Text(
                            documentSnapshot["title"],
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          subtitle: Row(
                            children: <Widget>[
                              Text(
                                "Last Date : ",
                                style: subtitles,
                              ),
                              Text(
                                DateFormat('d MMM,yyyy').format(d).toString(),
                                style: subtitles.copyWith(
                                    color:
                                        const Color.fromARGB(255, 37, 37, 37)),
                              )
                            ],
                          ),
                          children: <Widget>[
                            const Divider(
                              thickness: 1.0,
                              height: 1.0,
                            ),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                  vertical: 8.0,
                                ),
                                child: Text(
                                  documentSnapshot["desc"] ?? "",
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(fontSize: 16),
                                ),
                              ),
                            ),
                            Card(
                              color: Colors.white38,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      showDialog(
                                          context: context,
                                          builder: (context) {
                                            String? title;
                                            String? descriptionX;
                                            return CupertinoAlertDialog(
                                              title: const Text("Edit"),
                                              content: Form(
                                                  key: _formKey,
                                                  child: Column(
                                                    children: [
                                                      Material(
                                                        child: TextFormField(
                                                          decoration:
                                                              InputDecoration(
                                                            border:
                                                                const OutlineInputBorder(
                                                              borderSide:
                                                                  BorderSide(
                                                                color: Color
                                                                    .fromARGB(
                                                                        255,
                                                                        37,
                                                                        37,
                                                                        37),
                                                              ),
                                                            ),
                                                            focusedBorder:
                                                                OutlineInputBorder(
                                                              borderSide: const BorderSide(
                                                                  width: 2,
                                                                  color: Color
                                                                      .fromARGB(
                                                                          255,
                                                                          37,
                                                                          37,
                                                                          37)),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          5.0),
                                                            ),
                                                            prefixIcon:
                                                                const Icon(
                                                              Icons
                                                                  .event_available_outlined,
                                                              color: Color
                                                                  .fromARGB(
                                                                      255,
                                                                      37,
                                                                      37,
                                                                      37),
                                                            ),
                                                            hintText:
                                                                "Assignment title",
                                                          ),
                                                          initialValue:
                                                              documentSnapshot[
                                                                  "title"],
                                                          onChanged: (value) {
                                                            title = value;
                                                          },
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        height: 15,
                                                      ),
                                                      Material(
                                                        child: TextFormField(
                                                            decoration:
                                                                InputDecoration(
                                                              border:
                                                                  const OutlineInputBorder(
                                                                borderSide:
                                                                    BorderSide(
                                                                  color: Color
                                                                      .fromARGB(
                                                                          255,
                                                                          37,
                                                                          37,
                                                                          37),
                                                                ),
                                                              ),
                                                              focusedBorder:
                                                                  OutlineInputBorder(
                                                                borderSide: const BorderSide(
                                                                    width: 2,
                                                                    color: Color
                                                                        .fromARGB(
                                                                            255,
                                                                            37,
                                                                            37,
                                                                            37)),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            5.0),
                                                              ),
                                                              prefixIcon:
                                                                  const Icon(
                                                                Icons
                                                                    .event_available_outlined,
                                                                color: Color
                                                                    .fromARGB(
                                                                        255,
                                                                        37,
                                                                        37,
                                                                        37),
                                                              ),
                                                              hintText:
                                                                  "Assignment title",
                                                            ),
                                                            initialValue:
                                                                documentSnapshot[
                                                                    "desc"],
                                                            onChanged:
                                                                ((value) {
                                                              descriptionX =
                                                                  value;
                                                            })),
                                                      ),
                                                      const SizedBox(
                                                        height: 20,
                                                      ),
                                                      dateSelectionButton,
                                                    ],
                                                  )),
                                              actions: [
                                                TextButton(
                                                    onPressed: () {
                                                      String getData(
                                                          String? name,
                                                          String already) {
                                                        if (name != null &&
                                                            name.isNotEmpty) {
                                                          return name;
                                                        } else {
                                                          return already;
                                                        }
                                                      }

                                                      AssignMentModel
                                                          assignmentX =
                                                          AssignMentModel();
                                                      assignmentX.id =
                                                          widget.userId;
                                                      assignmentX.desc =
                                                          getData(
                                                              descriptionX,
                                                              documentSnapshot[
                                                                  "desc"]);
                                                      assignmentX.title =
                                                          getData(
                                                              title,
                                                              documentSnapshot[
                                                                  "title"]);
                                                      assignmentX.assignedBy =
                                                          documentSnapshot[
                                                              "assignedBy"];
                                                      assignmentX.url =
                                                          documentSnapshot[
                                                              "url"];
                                                      assignmentX.subject =
                                                          documentSnapshot[
                                                              "subject"];
                                                      Timestamp date =
                                                          documentSnapshot[
                                                                  "assignedDate"]
                                                              as Timestamp;
                                                      DateTime ad =
                                                          date.toDate();
                                                      assignmentX.assignedDate =
                                                          ad;
                                                      assignmentX.lastDate =
                                                          currentDate ?? d;
                                                      assignmentX.toBranch =
                                                          documentSnapshot[
                                                              "toBranch"];
                                                      assignmentX.year =
                                                          documentSnapshot[
                                                              "year"];
                                                      assignmentX.assignmentId =
                                                          documentSnapshot[
                                                              "assignmentId"];
                                                      final isValid = _formKey
                                                          .currentState!
                                                          .validate();
                                                      if (isValid) {
                                                        assignment
                                                            .doc(documentSnapshot[
                                                                "assignmentId"])
                                                            .update(assignmentX
                                                                .toMap())
                                                            .then(
                                                              (value) =>
                                                                  Navigator.pop(
                                                                      context),
                                                            );
                                                      }
                                                    },
                                                    child: const Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: [
                                                        Icon(Icons.edit),
                                                        Text("Edit")
                                                      ],
                                                    ))
                                              ],
                                            );
                                          });
                                    },
                                    icon: const Icon(Icons.edit),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      showLoading
                                          ? const CircularProgressIndicator()
                                          : showDialog(
                                              context: context,
                                              builder: ((context) =>
                                                  AlertDialog(
                                                    actionsAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    backgroundColor:
                                                        const Color.fromARGB(
                                                            255, 37, 37, 37),
                                                    contentPadding:
                                                        const EdgeInsets.all(
                                                            12.0),
                                                    title: const Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: <Widget>[
                                                          Text(
                                                            "Are you sure ?",
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 18,
                                                            ),
                                                          ),
                                                          CloseButton(
                                                            color: Colors.white,
                                                          ),
                                                        ]),
                                                    content: const Text(
                                                      "This will delete the assignment from database for ever!!",
                                                      style: TextStyle(
                                                        color: Colors.white54,
                                                      ),
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                    actions: [
                                                      appButton(
                                                        Colors.black,
                                                        () {
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                        Icons.cancel,
                                                        const Text("Cancel"),
                                                        Colors.white,
                                                      ),
                                                      appButton(
                                                        Colors.black,
                                                        () {
                                                          assignment
                                                              .doc(documentSnapshot[
                                                                  "assignmentId"])
                                                              .delete()
                                                              .then(
                                                            (value) {
                                                              print(
                                                                  "Deleted Succefully");
                                                              setState(() {
                                                                showLoading =
                                                                    true;
                                                              });
                                                            },
                                                          );
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                        Icons.delete_forever,
                                                        const Text("Delete"),
                                                        Colors.red,
                                                      ),
                                                    ],
                                                  )),
                                            );
                                    },
                                    icon: const Icon(Icons.delete),
                                  ),
                                  IconButton(
                                      onPressed: () {
                                        Navigator.push(context,
                                            MaterialPageRoute(
                                                builder: (context) {
                                          return AssignmentResponse(
                                              id: documentSnapshot[
                                                      "assignmentId"] ??
                                                  "");
                                        }));
                                      },
                                      icon: const Icon(Icons.file_open))
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  });
            }
          }),
    );
  }
}

class AlertForDelete extends StatefulWidget {
  final String assignmentId;
  final CollectionReference assignment;
  const AlertForDelete(
      {super.key, required this.assignment, required this.assignmentId});

  @override
  State<AlertForDelete> createState() => _AlertForDeleteState();
}

class _AlertForDeleteState extends State<AlertForDelete> {
  @override
  Widget build(BuildContext context) {
    Widget appButton(
      Color? color,
      Function action,
      Icon icon,
      Text label,
    ) {
      return TextButton.icon(
        onPressed: () {
          action;
        },
        icon: icon,
        label: label,
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(color),
          foregroundColor: MaterialStateProperty.all(Colors.white),
        ),
      );
    }

    return AlertDialog(
      backgroundColor: const Color.fromARGB(255, 37, 37, 37),
      contentPadding: const EdgeInsets.all(12.0),
      title: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              "Are you sure ?",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            CloseButton(),
          ]),
      content: const Text(
          "This will delete the assignment from database for ever!!"),
      actions: [
        appButton(
          Colors.black,
          () {
            Navigator.pop(context);
          },
          const Icon(Icons.cancel),
          const Text("Cancel"),
        ),
        appButton(
          Colors.black,
          () {
            widget.assignment.doc(widget.assignmentId).delete().then(
              (value) {
                print("Deleted Succefully");
                Navigator.pop(context);
              },
            );
          },
          const Icon(Icons.delete_forever),
          const Text("Delete"),
        )
      ],
    );
  }
}
