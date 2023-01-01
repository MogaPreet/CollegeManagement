import 'package:cloud_firestore/cloud_firestore.dart';
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

final selectedYear = StateProvider<List<String>?>((ref) {
  return [""];
});

class SubjectYear extends ConsumerStatefulWidget {
  const SubjectYear({super.key});

  @override
  ConsumerState<SubjectYear> createState() => _SubjectYearState();
}

class _SubjectYearState extends ConsumerState<SubjectYear> {
  static final List<String> itSubjects = [
    "MATHS 1 SEM",
    "PSP",
    "Data Structure",
    "JAVA",
    "DBMS",
  ];
  static final List<String> compsSubjects = [
    "MATHS 3",
    "DLCA",
    "Data Structure",
    "JAVA",
    "DISCRIET MATHS",
  ];
  @override
  Widget build(BuildContext context) {
    // void _showMultiSelect(BuildContext context) async {
    //   await showDialog(
    //     context: context,
    //     builder: (ctx) {
    //       return MultiSelectDialog(
    //         items: _items,
    //         initialValue: _selectedAnimals,
    //         onConfirm: (values) {},
    //       );
    //     },
    //   );
    // }

    final myBranches = ref.watch(selectedBranchs);
    List<String>? showSubjects = [];
    if (myBranches.contains("IT")) {
      showSubjects.addAll(itSubjects);
      if (myBranches.contains("COMPS")) {
        showSubjects.addAll(compsSubjects);
      }
    }
    final items = showSubjects
        .map((subject) => MultiSelectItem<String>(subject, subject))
        .toList();
    List<String> selectedSubject = [];
    return MultiSelectBottomSheetField(
      initialChildSize: 0.4,
      listType: MultiSelectListType.CHIP,
      searchable: true,
      buttonText: const Text("Select Subjects"),
      title: const Text("Subjects"),
      items: items,
      onConfirm: (values) {
        selectedSubject = values.cast();
        ref.watch(selectedSubjects.notifier).update((state) => selectedSubject);
      },
      chipDisplay: MultiSelectChipDisplay(
        onTap: (value) {
          setState(() {
            selectedSubject.remove(value);
          });
        },
      ),
    );
  }
}
