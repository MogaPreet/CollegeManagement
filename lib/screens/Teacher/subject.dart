import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cms/models/subjects.dart';
import 'package:cms/screens/Student/widgets/progressIndicator.dart';
import 'package:cms/screens/teacher_signup.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:multi_select_flutter/bottom_sheet/multi_select_bottom_sheet_field.dart';
import 'package:multi_select_flutter/chip_display/multi_select_chip_display.dart';
import 'package:multi_select_flutter/dialog/mult_select_dialog.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:multi_select_flutter/util/multi_select_list_type.dart';
import 'package:riverpod/riverpod.dart';

final selectedYear = StateProvider.autoDispose<List<String>>((ref) {
  return [""];
});

class SubjectYear extends ConsumerStatefulWidget {
  final List<String> myBranches;
  final String forYear;
  final StateProvider<List<String>> selectedYear;
  const SubjectYear(
      {super.key,
      required this.myBranches,
      required this.forYear,
      required this.selectedYear});

  @override
  ConsumerState<SubjectYear> createState() => _SubjectYearState();
}

class _SubjectYearState extends ConsumerState<SubjectYear> {
  Subject subjects = Subject();

  List<String> showSubjects = [];
  List<String> display(List<String> myBranches, WidgetRef ref, String forYear) {
    Subject subjects = Subject();
    List<String> showThis = [];

    final year = ref.watch(selectedYear);

    FirebaseFirestore.instance
        .collection("yearMaster")
        .where("year", isEqualTo: forYear)
        .get()
        .then((value) {
      for (var ele in value.docs) {
        subjects = Subject.fromMap(ele.data());
        int i = 0;
        while (i < myBranches.length) {
          if (myBranches[i] == "Artificial Intelligence & Data Science") {
            showThis.addAll(subjects.aids ?? []);
          }
          if (myBranches[i] == "Civil Engineering") {
            showThis.addAll(subjects.civilEngg ?? []);
          }
          if (myBranches[i] == "Computer Engineering") {
            showThis.addAll(subjects.compsEngg ?? []);
          }
          if (myBranches[i] == "Electrical Engineering") {
            showThis.addAll(subjects.electricalEngg ?? []);
          }
          if (myBranches[i] == "Electronics Engineering") {
            showThis.addAll(subjects.electronicEngg ?? []);
          }
          if (myBranches[i] == "Information Technology") {
            showThis.addAll(subjects.infoTech ?? []);
          }
          if (myBranches[i] == "Mechanical Engineering") {
            showThis.addAll(subjects.mechEngg ?? []);
          }
          i++;
        }
        // showThis = subjects.aids! +
        //     subjects.compsEngg! +
        //     subjects.civilEngg! +
        //     subjects.electricalEngg! +
        //     subjects.electronicEngg! +
        //     subjects.infoTech! +
        //     subjects.mechEngg!;
      }

      ref.watch(selectedYear.notifier).update((state) => showThis);
    });

    return year;
  }

  @override
  Widget build(BuildContext context) {
    final items = display(widget.myBranches, ref, widget.forYear)
        .toList()
        .map((subject) => MultiSelectItem<String>(subject, subject))
        .toList();
    List<String> selectedSubject = [];
    Widget mulBottom = MultiSelectBottomSheetField(
      initialChildSize: 0.4,
      listType: MultiSelectListType.CHIP,
      searchable: true,
      buttonText: const Text("Select Subjects"),
      title: const Text("Subjects"),
      items: items,
      onConfirm: (values) {
        selectedSubject = values.cast();
        ref
            .watch(widget.selectedYear.notifier)
            .update((state) => selectedSubject);
      },
      chipDisplay: MultiSelectChipDisplay(
        onTap: (value) {
          // setState(() {
          //   selectedSubject.remove(value);
          //   ref
          //       .watch(widget.selectedYear.notifier)
          //       .update((state) => selectedSubject);
          // });
        },
      ),
    );
    if (items.isNotEmpty) {
      return mulBottom;
    }
    return ProgressIndication(
      child: mulBottom,
    );
  }
}
