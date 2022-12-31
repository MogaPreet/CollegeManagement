import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cms/models/notice.dart';
import 'package:cms/models/user.dart';
import 'package:cms/screens/Teacher/home.dart';
import 'package:cms/screens/signup.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final isOptionSelected = StateProvider.autoDispose((ref) {
  return false;
});

class Notice extends ConsumerStatefulWidget {
  TeacherModel notifier;
  Notice({super.key, required this.notifier});

  @override
  ConsumerState<Notice> createState() => _NoticeState();
}

class _NoticeState extends ConsumerState<Notice> {
  final _formKey = GlobalKey<FormState>();
  String? url;
  final noticeTitleController = TextEditingController();
  final noticeDescController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    final noticeTitle = TextFormField(
      controller: noticeTitleController,
      validator: (value) {
        if (value != null && value.isEmpty) {
          return "Notice Name is Required";
        } else {
          return null;
        }
      },
      onSaved: (value) {
        noticeTitleController.text = value!;
      },
      decoration: InputDecoration(
        border: const OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.black,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(width: 2, color: Colors.black),
          borderRadius: BorderRadius.circular(5.0),
        ),
        prefixIcon: const Icon(
          Icons.event_available_outlined,
          color: Colors.black,
        ),
        hintText: "Notice title",
      ),
    );
    final noticeDesc = TextFormField(
      controller: noticeDescController,
      minLines: 1,
      maxLines: 10,
      validator: (value) {
        if (value!.isEmpty) {
          return "Notice detail is Required";
        } else {
          return null;
        }
      },
      onSaved: (value) {
        noticeDescController.text = value ?? "";
      },
      keyboardType: TextInputType.multiline,
      decoration: InputDecoration(
        border: const OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.black,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(width: 2, color: Colors.black),
          borderRadius: BorderRadius.circular(5.0),
        ),
        prefixIcon: const Icon(
          Icons.description_outlined,
          color: Colors.black,
        ),
        hintText: "Event Description",
      ),
    );
    List<String> branch = [
      'COMPS',
      'IT',
      'EXTC',
      'PLASTIC',
      'CIVIL',
      'CHEMICAL'
    ];
    List<String> currentb = [
      widget.notifier.branch ?? "S",
    ];
    List<String>? sendNoticeTo() {
      final selection = ref.watch(isOptionSelected);
      print(selection);
      print(currentb);
      if (selection) {
        return branch;
      } else {
        return currentb;
      }
    }

    void addNotice() async {
      final isValid = _formKey.currentState!.validate();
      var date = DateTime.now().toString();

      var dateparse = DateTime.parse(date);

      if (isValid) {
        _formKey.currentState!.save();
        try {
          // final id = uuid.v4();

          NoticeModel notice = NoticeModel();
          notice.id = int.tryParse(widget.notifier.uid ?? "");
          notice.notifiedBy = widget.notifier.firstName;
          notice.title = noticeTitleController.text;
          notice.desc = noticeDescController.text;
          notice.url = "";
          notice.toBranch = sendNoticeTo();
          notice.createdAt = Timestamp.now().toDate().toString();
          await FirebaseFirestore.instance
              .collection('notices')
              .doc()
              .set(notice.toMap());

          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const TeacherHome()),
              (route) => false);
        } catch (error) {
          print('error occured ${error}');
        } finally {
          // setState(() {
          //   _isLoading = false;
          // });
        }
      }
    }

    final currentSelection = ref.watch(isOptionSelected);
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
          child: NotificationListener<OverscrollIndicatorNotification>(
            onNotification: ((overscroll) {
              overscroll.disallowIndicator();
              return true;
            }),
            child: Form(
                key: _formKey,
                child: ListView(
                  children: <Widget>[
                    const SizedBox(
                      height: 15,
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          "Add Notice",
                        ),
                        noticeTitle,
                        const SizedBox(
                          height: 20,
                        ),
                        noticeDesc,
                        const SizedBox(
                          height: 20,
                        ),
                        Row(
                          children: [
                            Checkbox(
                                value: currentSelection,
                                onChanged: (value) {
                                  ref
                                      .watch(isOptionSelected.notifier)
                                      .update((state) {
                                    if (value != null) {
                                      return ref
                                          .watch(isOptionSelected.notifier)
                                          .update((state) => value);
                                    }
                                    return currentSelection;
                                  });
                                }),
                            const Text("Send this notificataion to all branch ")
                          ],
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        TextButton(
                            onPressed: () {
                              addNotice();
                            },
                            child: const Text("Add Notice"))
                      ],
                    )
                  ],
                )),
          ),
        ),
      ),
    );
  }
}
