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
        FirebaseFirestore.instance.collection('assignemnts');
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
          stream: assignment.where("id", isEqualTo: widget.userId).snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return const Text('Something went wrong');
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Column(
                children: const [Center(child: CupertinoActivityIndicator())],
              );
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
                          textColor: Color.fromARGB(255, 37, 37, 37),
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
                                    onPressed: () {},
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
