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
    print("My Branch is equal  ${widget.myBranch}");
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10),
      child: Column(
        children: [
          const ForDse(),
          StreamBuilder<QuerySnapshot>(
              stream: students
                  .where("branch", whereIn: widget.myBranch)
                  .where("currentYear", isEqualTo: selectedYear)
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return const Text('Something went wrong');
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Column(
                    children: [Center(child: CupertinoActivityIndicator())],
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
                            leading: const Icon(Icons.person_rounded),
                            title: Text(documentSnapshot["firstName"]),
                            trailing: GestureDetector(
                                onTap: () {
                                  showGeneralDialog(
                                      context: context,
                                      barrierDismissible: true,
                                      barrierLabel:
                                          MaterialLocalizations.of(context)
                                              .modalBarrierDismissLabel,
                                      barrierColor: Colors.black45,
                                      transitionDuration:
                                          const Duration(milliseconds: 200),
                                      pageBuilder: (BuildContext buildContext,
                                          Animation animation,
                                          Animation secondaryAnimation) {
                                        return Center(
                                          child: Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width -
                                                10,
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height -
                                                80,
                                            padding: const EdgeInsets.all(20),
                                            color: Colors.white,
                                            child: Column(
                                              children: [
                                                Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    const Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          "First Name :",
                                                          style: TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 14,
                                                            decoration:
                                                                TextDecoration
                                                                    .none,
                                                          ),
                                                        ),
                                                        Text(
                                                          "Last Name :",
                                                          style: TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 14,
                                                            decoration:
                                                                TextDecoration
                                                                    .none,
                                                          ),
                                                        ),
                                                        Text(
                                                          "Email :",
                                                          style: TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 14,
                                                            decoration:
                                                                TextDecoration
                                                                    .none,
                                                          ),
                                                        ),
                                                        Text(
                                                          "Roll No :",
                                                          style: TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 14,
                                                            decoration:
                                                                TextDecoration
                                                                    .none,
                                                          ),
                                                        ),
                                                        Text(
                                                          "Branch :",
                                                          style: TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 14,
                                                            decoration:
                                                                TextDecoration
                                                                    .none,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          documentSnapshot[
                                                                  "firstName"] ??
                                                              "",
                                                          style:
                                                              const TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 14,
                                                            decoration:
                                                                TextDecoration
                                                                    .none,
                                                          ),
                                                        ),
                                                        Text(
                                                          documentSnapshot[
                                                                  "lastName"] ??
                                                              "",
                                                          style:
                                                              const TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 14,
                                                            decoration:
                                                                TextDecoration
                                                                    .none,
                                                          ),
                                                        ),
                                                        Text(
                                                          documentSnapshot[
                                                                  "email"] ??
                                                              "",
                                                          style:
                                                              const TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 14,
                                                            decoration:
                                                                TextDecoration
                                                                    .none,
                                                          ),
                                                        ),
                                                        Text(
                                                          documentSnapshot[
                                                                  "rollNo"] ??
                                                              "",
                                                          style:
                                                              const TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 14,
                                                            decoration:
                                                                TextDecoration
                                                                    .none,
                                                          ),
                                                        ),
                                                        Text(
                                                          documentSnapshot[
                                                                  "branch"] ??
                                                              "",
                                                          style:
                                                              const TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 14,
                                                            decoration:
                                                                TextDecoration
                                                                    .none,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                                Spacer(),
                                                ElevatedButton(
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: const Text(
                                                    "Ok",
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        );
                                      });
                                },
                                child:
                                    const Icon(Icons.arrow_circle_right_sharp)),
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
