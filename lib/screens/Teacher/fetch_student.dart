import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cms/screens/signup.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FetchStudent extends ConsumerStatefulWidget {
  final List<String> myBranch;
  const FetchStudent({super.key, required this.myBranch});

  @override
  ConsumerState<FetchStudent> createState() => _FetchStudentState();
}

class _FetchStudentState extends ConsumerState<FetchStudent> {
  @override
  Widget build(BuildContext context) {
    final selectedYear = ref.watch(currentYear);
    CollectionReference students =
        FirebaseFirestore.instance.collection('students');

    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10),
      child: Column(
        children: [
          const ForDse(),
          StreamBuilder<QuerySnapshot>(
              stream: students
                  .where("branch", arrayContainsAny: widget.myBranch)
                  .where("currentYear", isEqualTo: selectedYear)
                  .snapshots(includeMetadataChanges: true),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
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
                          return ListTile(
                            leading: Icon(Icons.person_rounded),
                            title: Text(documentSnapshot["firstName"]),
                            trailing: Icon(Icons.arrow_circle_right_sharp),
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
