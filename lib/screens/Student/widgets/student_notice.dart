import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cms/models/notice.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final showViewMore = StateProvider.autoDispose((ref) {
  return false;
});
final limit = StateProvider.autoDispose((ref) {
  final showM = ref.watch(showViewMore);
  if (showM) {
    return 20;
  } else {
    return 3;
  }
});

class StudNotice extends ConsumerStatefulWidget {
  final String mybranch;
  const StudNotice({super.key, required this.mybranch});

  @override
  ConsumerState<StudNotice> createState() => _StudNoticeState();
}

class _StudNoticeState extends ConsumerState<StudNotice> {
  NoticeModel notice = NoticeModel();

  @override
  Widget build(BuildContext context) {
    CollectionReference notices =
        FirebaseFirestore.instance.collection('notices');
    print(widget.mybranch);
    final showLimit = ref.watch(limit);
    return StreamBuilder<QuerySnapshot>(
        stream: notices
            .where("toBranch", arrayContains: widget.mybranch)
            .limit(showLimit)
            .snapshots(includeMetadataChanges: true),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Text('Something went wrong');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CupertinoActivityIndicator());
          }
          final dres = snapshot.data!.docs.map((e) => e.data());
          final bane = dres.map((e) => e as NoticeModel).map((e) => e.title);
          var len = snapshot.data?.docs.length ?? 909;

          final today = DateTime.now();
          return Column(
            children: [
              ListView.builder(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  itemCount: len,
                  padding: EdgeInsets.only(left: 10, right: 10),
                  itemBuilder: (context, index) {
                    final DocumentSnapshot documentSnapshot =
                        snapshot.data!.docs[index];

                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: documentSnapshot["createdAt"]
                                  .toString()
                                  .substring(0, 10) ==
                              today.toString().substring(0, 10)
                          ? const Icon(
                              Icons.fiber_new_sharp,
                              color: Colors.red,
                            )
                          : const Icon(Icons.feed_rounded),
                      title: Text(
                        documentSnapshot["title"],
                        maxLines: 1,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      trailing: GestureDetector(
                          onTap: () {
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    insetPadding: const EdgeInsets.symmetric(
                                        horizontal: 25.0, vertical: 20.0),
                                    title: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Notice",
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 16,
                                              ),
                                            ),
                                            Text(
                                              documentSnapshot["createdAt"]
                                                  .toString()
                                                  .substring(0, 19),
                                              style: TextStyle(
                                                fontWeight: FontWeight.w300,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                        CloseButton(),
                                      ],
                                    ),
                                    content: SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.3,
                                      width: MediaQuery.of(context).size.width *
                                          0.8,
                                      child: SingleChildScrollView(
                                        physics: BouncingScrollPhysics(),
                                        child: Text(
                                          documentSnapshot["desc"],
                                        ),
                                      ),
                                    ),
                                  );
                                });
                          },
                          child: const Icon(Icons.arrow_circle_right_sharp)),
                    );
                  }),
              if (len >= 3)
                TextButton(
                    onPressed: () {
                      ref.watch(showViewMore.notifier).update((state) => true);
                      if (showLimit > 3) {
                        ref
                            .watch(showViewMore.notifier)
                            .update((state) => false);
                      }
                    },
                    child: Text(showLimit > 3 ? "Show Less" : "Show More"))
            ],
          );
        });
  }
}
