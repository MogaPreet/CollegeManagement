import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ShowAssignment extends StatefulWidget {
  String userId;
  ShowAssignment({super.key, required this.userId});

  @override
  State<ShowAssignment> createState() => _ShowAssignmentState();
}

class _ShowAssignmentState extends State<ShowAssignment> {
  @override
  Widget build(BuildContext context) {
    CollectionReference assignment =
        FirebaseFirestore.instance.collection('assignemnts');
    return Scaffold(
      body: Column(
        children: [
          StreamBuilder<QuerySnapshot>(
              stream:
                  assignment.where("id", isEqualTo: widget.userId).snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return const Text('Something went wrong');
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Column(
                    children: const [
                      Center(child: CupertinoActivityIndicator())
                    ],
                  );
                }
                final dres = snapshot.data!.docs.map((e) => e.data());

                var len = snapshot.data?.docs.length ?? 909;

                print("Length $len");

                return Column(
                  children: [
                    ListView.builder(
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        physics: const BouncingScrollPhysics(),
                        itemCount: len,
                        itemBuilder: (context, index) {
                          final DocumentSnapshot documentSnapshot =
                              snapshot.data!.docs[index];
                          return Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Card(
                              color: Colors.white24,
                              child: ExpansionTile(
                                textColor: Colors.black,
                                title: Text(documentSnapshot["title"]),
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
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      IconButton(
                                        onPressed: () {},
                                        icon: Icon(Icons.edit),
                                      ),
                                      IconButton(
                                        onPressed: () {},
                                        icon: Icon(Icons.delete),
                                      )
                                    ],
                                  )
                                ],
                              ),
                            ),
                          );
                        }),
                    // if (len >= 3)
                    //   TextButton(
                    //       onPressed: () {
                    //         ref.watch(showViewMore.notifier).update((state) => true);
                    //         if (showLimit > 3) {
                    //           ref
                    //               .watch(showViewMore.notifier)
                    //               .update((state) => false);
                    //         }
                    //       },
                    //       child: Text(showLimit > 3 ? "Show Less" : "Show More"))
                  ],
                );
              }),
        ],
      ),
    );
  }
}
