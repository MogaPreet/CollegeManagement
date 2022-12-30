import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cms/models/notice.dart';
import 'package:cms/screens/Teacher/notice.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod/riverpod.dart';

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
            return Column(
              children: [const Center(child: CupertinoActivityIndicator())],
            );
          }
          final dres = snapshot.data!.docs.map((e) => e.data());
          final bane = dres.map((e) => e as NoticeModel).map((e) => e.title);
          var len = snapshot.data?.docs.length ?? 909;

          print("Length $len");

          return Column(
            children: [
              ListView.builder(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  physics: BouncingScrollPhysics(),
                  itemCount: len,
                  itemBuilder: (context, index) {
                    final DocumentSnapshot documentSnapshot =
                        snapshot.data!.docs[index];
                    return ListTile(
                      leading: Icon(Icons.newspaper),
                      title: Text(documentSnapshot["title"]),
                      trailing: Icon(Icons.arrow_circle_right_sharp),
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
