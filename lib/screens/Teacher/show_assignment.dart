import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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

    bool showLoading = false;
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
          stream: assignment.where("id", isEqualTo: widget.userId).snapshots(),
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
                                      .bodyText2
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
                                    onPressed: () {},
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
                                                    title: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: const <
                                                            Widget>[
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
                                  )
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
      title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const <Widget>[
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