import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cms/models/subjects.dart';
import 'package:cms/models/user.dart';
import 'package:cms/screens/Teacher/home.dart';
import 'package:cms/screens/Teacher/subject.dart';
import 'package:cms/screens/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:multi_select_flutter/bottom_sheet/multi_select_bottom_sheet_field.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:multi_select_flutter/util/multi_select_list_type.dart';
import 'package:shared_preferences/shared_preferences.dart';

final selBranch = StateProvider<String>((ref) {
  return "COMPS";
});
final selectedBranchs = StateProvider<List<String>>((ref) {
  return [];
});
final yearList = StateProvider<List<String>>((ref) {
  return [];
});
final year1 = StateProvider<List<String>>((ref) {
  return [];
});

final year2 = StateProvider<List<String>>((ref) {
  return [];
});

final year3 = StateProvider<List<String>>((ref) {
  return [];
});

final year4 = StateProvider<List<String>>((ref) {
  return [];
});

class BranchSelction extends ConsumerWidget {
  const BranchSelction({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dropdownvalue = ref.watch(selBranch);
    var branch = [
      'Artificial Intelligence & Data Science',
      'Civil Engineering',
      'Computer Engineering',
      'Electrical Engineering',
      'Electronics Engineering',
      'Information Technology',
      'Mechanical Engineering'
    ];
    final items = branch
        .map((branch) => MultiSelectItem<String>(branch, branch))
        .toList();
    List<String>? selectedBranch = ref.watch(selectedBranchs);

    void showMultiSelect(BuildContext context) async {
      await showDialog(
        context: context,
        builder: (ctx) {
          return MultiSelectDialog(
            items: items,
            initialValue: selectedBranch ?? [],
            onConfirm: (values) {
              selectedBranch = values.cast();
              ref
                  .watch(selectedBranchs.notifier)
                  .update((state) => selectedBranch ?? []);
            },
          );
        },
      );
    }

    return Column(
      children: [
        GestureDetector(
            onTap: () {
              showMultiSelect(context);
            },
            child: const Text("Select Branch")),
        const SizedBox(
          height: 10,
        ),
        Text("Selected Branches are : $selectedBranch"),
      ],
    );
  }
}

final selectedSubjects = StateProvider<List<String>>((ref) {
  return [];
});

class TeacherSignup extends ConsumerStatefulWidget {
  const TeacherSignup({super.key});

  @override
  ConsumerState<TeacherSignup> createState() => _TeacherSignupState();
}

class _TeacherSignupState extends ConsumerState<TeacherSignup> {
  final firstNameEditingController = TextEditingController();
  final lastNameEditingController = TextEditingController();
  final emailEditingController = TextEditingController();
  final passwordEditingController = TextEditingController();
  final confirmPasswordEditingController = TextEditingController();
  bool _isLoading = false;
  final _auth = FirebaseAuth.instance;
  SharedPreferences? loginData;
  String? errorMessage;
  final _formKey = GlobalKey<FormState>();
  static final List<String> _itSubjects = [
    "MATHS 3",
    "PSP",
    "Data Structure",
    "JAVA",
    "DBMS",
  ];
  static final List<String> _compsSubjects = [
    "MATHS 3",
    "DLCA",
    "Data Structure",
    "JAVA",
    "DISCRIET MATHS",
  ];

  int code() {
    final subject = ref.watch(selBranch);
    switch (subject) {
      case "IT":
        return 1;
      case "COMPS":
        return 2;
      default:
        return 1;
    }
  }

  List<String> theSubject() {
    switch (code()) {
      case 1:
        return _itSubjects;
      case 2:
        return _compsSubjects;
      case 3:
      default:
        return _compsSubjects;
    }
  }

  @override
  Widget build(BuildContext context) {
    //fields
    final firstNameField = TextFormField(
      autofocus: false,
      controller: firstNameEditingController,
      keyboardType: TextInputType.name,
      validator: (value) {
        RegExp regex = RegExp(r'^.{3,}$');
        if (value!.isEmpty) {
          return ("First Name is required");
        }
        if (!regex.hasMatch(value)) {
          return ("Enter valid name min 3 character");
        }
        return null;
      },
      onSaved: (value) {
        firstNameEditingController.text = value!;
      },
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
          prefixIcon: const Icon(Icons.account_circle),
          contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
          hintText: "First Name",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          )),
    );

    final lastNameField = TextFormField(
      autofocus: false,
      controller: lastNameEditingController,
      keyboardType: TextInputType.name,
      //validator: () {},
      onSaved: (value) {
        lastNameEditingController.text = value!;
      },
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
          prefixIcon: const Icon(Icons.account_circle),
          contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
          hintText: "Last Name",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          )),
    );

    final emailField = TextFormField(
      autofocus: false,
      controller: emailEditingController,
      keyboardType: TextInputType.emailAddress,
      validator: (value) {
        if (value!.isEmpty) {
          return ("Please Enter Your Email");
        }
        if (!RegExp("^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+.[a-z]").hasMatch(value)) {
          return ("Please Enter Valid Email");
        }
        return null;
      },
      onSaved: (value) {
        emailEditingController.text = value!;
      },
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
          prefixIcon: const Icon(Icons.email),
          contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
          hintText: "Email",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          )),
    );

    final passwordField = TextFormField(
      autofocus: false,
      controller: passwordEditingController,
      obscureText: true,
      validator: (value) {
        RegExp regex = RegExp(r'^.{6,}$');
        if (value!.isEmpty) {
          return ("Password is required for login");
        }
        if (!regex.hasMatch(value)) {
          return ("Please Enter Valid Password min 6 character");
        }
        return null;
      },
      onSaved: (value) {
        passwordEditingController.text = value!;
      },
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
          prefixIcon: const Icon(Icons.lock),
          contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
          hintText: "Password",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          )),
    );

    final confirmPasswordField = TextFormField(
      autofocus: false,
      controller: confirmPasswordEditingController,
      obscureText: true,
      validator: (value) {
        if (confirmPasswordEditingController.text !=
            passwordEditingController.text) {
          return "password not matched";
        }
        return null;
      },
      onSaved: (value) {
        confirmPasswordEditingController.text = value!;
      },
      textInputAction: TextInputAction.done,
      decoration: InputDecoration(
          prefixIcon: const Icon(Icons.lock),
          contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
          hintText: "Confirm Password",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          )),
    );

    final signUpButton = Material(
        elevation: 5,
        borderRadius: BorderRadius.circular(5),
        color: const Color.fromARGB(255, 0, 0, 0),
        child: MaterialButton(
          padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
          minWidth: MediaQuery.of(context).size.width,
          onPressed: () async {
            signUp(
              emailEditingController.text,
              passwordEditingController.text,
            );
          },
          child: _isLoading
              ? const SizedBox(
                  width: 20.0,
                  height: 20.0,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                )
              : const Text(
                  "Sign Up",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20.0,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Let's Know About You!",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 37, 37, 37),
          ),
        ),
        scrolledUnderElevation: .1,
        toolbarOpacity: 0.0,
        bottomOpacity: 0.0,
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    margin: const EdgeInsets.only(right: 15),
                    child: SizedBox(
                      width: 200.0,
                      child: Image.asset(
                        "assets/signup.png",
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  firstNameField,
                  const SizedBox(height: 20),
                  lastNameField,
                  const SizedBox(height: 20),
                  const BranchSelction(),
                  const SizedBox(height: 20),
                  // SubjectYear(),
                  SubjectSel(
                    forYear: "First Year",
                    selectedYear: year1,
                  ),
                  const SizedBox(height: 20),
                  SubjectSel(
                    forYear: "Second Year",
                    selectedYear: year2,
                  ),
                  const SizedBox(height: 20),
                  SubjectSel(
                    forYear: "Third Year",
                    selectedYear: year3,
                  ),
                  const SizedBox(height: 20),
                  SubjectSel(
                    forYear: "Fourth Year",
                    selectedYear: year4,
                  ),
                  const SizedBox(height: 20),
                  const SizedBox(height: 20),
                  emailField,
                  const SizedBox(height: 20),
                  passwordField,
                  const SizedBox(height: 20),
                  confirmPasswordField,
                  const SizedBox(height: 20),
                  signUpButton,
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const Text("Already have an account? "),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const LoginScreen()));
                        },
                        child: const Text(
                          "Sign In",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15.0,
                              color: Colors.redAccent),
                        ),
                      )
                    ],
                  )
                ],
              )),
        ),
      ),
    );
  }

  void signUp(
    String email,
    String password,
  ) async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      await _auth
          .createUserWithEmailAndPassword(
            email: email,
            password: password,
          )
          .then(
            (value) => {
              postDetailsToFirestore(ref),
            },
          )
          .catchError((error) {
        switch (error.code) {
          case "invalid-email":
            errorMessage = "Your email address appears to be malformed.";
            break;
          case "email-already-in-use":
            errorMessage = "The account already exists for that email.";
            break;
          case "wrong-password":
            errorMessage = "Your password is wrong.";
            break;
          case "user-not-found":
            errorMessage = "User with this email doesn't exist.";
            break;
          case "user-disabled":
            errorMessage = "User with this email has been disabled.";
            break;
          case "too-many-requests":
            errorMessage = "Too many requests";
            break;
          case "operation-not-allowed":
            errorMessage = "Signing in with Email and Password is not enabled.";
            break;
          default:
            errorMessage = "An undefined Error happened.";
        }
        Fluttertoast.showToast(msg: errorMessage!);
        _isLoading = false;
      });
    }
  }

  postDetailsToFirestore(
    WidgetRef ref,
  ) async {
    FirebaseFirestore firebaseFireStore = FirebaseFirestore.instance;
    User? user = _auth.currentUser;
    TeacherModel teacherModel = TeacherModel();
    List<String>? selectedBranch = ref.watch(selectedBranchs);
    final selSub = ref.watch(selectedSubjects);
    teacherModel.email = user?.email;
    teacherModel.uid = user?.uid;
    teacherModel.firstName = firstNameEditingController.text;
    teacherModel.lastName = lastNameEditingController.text;
    teacherModel.branch = selectedBranch;
    teacherModel.classCoord = false;
    teacherModel.years = myYears(ref);
    await firebaseFireStore
        .collection("teachers")
        .doc(user?.uid)
        .set(teacherModel.toMap());

    ref.watch(isTeacher.notifier).update((state) => true);
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isLoggedIn', true);
    prefs.setBool('isTeacher', true);
    await addSubjectsToDb(user!.uid, ref);
    if (!mounted) return;
    Fluttertoast.showToast(msg: "Account Created Successfully");
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const TeacherHome()),
        (route) => false);
  }
}

Future<String>? addSubjectsToDb(String id, WidgetRef ref) async {
  TeacherSubjects teacherSubjects = TeacherSubjects();
  final yearFirst = ref.watch(year1);
  final yearSecond = ref.watch(year2);
  final yearThird = ref.watch(year3);
  final yearFourth = ref.watch(year4);

  CollectionReference teacher =
      FirebaseFirestore.instance.collection("teachers");
  CollectionReference<Map<String, dynamic>> dbRef =
      teacher.doc(id).collection("subjects");

  teacherSubjects.year = "First Year";
  teacherSubjects.subjects = yearFirst;
  await dbRef.add(teacherSubjects.toJson());
  teacherSubjects.year = "Second Year";
  teacherSubjects.subjects = yearSecond;
  await dbRef.add(teacherSubjects.toJson());
  teacherSubjects.year = "Third Year";
  teacherSubjects.subjects = yearThird;
  await dbRef.add(teacherSubjects.toJson());
  teacherSubjects.year = "Fourth Year";
  teacherSubjects.subjects = yearFourth;
  await dbRef.add(teacherSubjects.toJson());
  return 'Success';
}

final isTeacher = StateProvider<bool>((ref) {
  return false;
});

class SubjectSel extends ConsumerStatefulWidget {
  final String forYear;
  final StateProvider<List<String>> selectedYear;
  const SubjectSel(
      {super.key, required this.forYear, required this.selectedYear});

  @override
  ConsumerState<SubjectSel> createState() => _SubjectSelState();
}

class _SubjectSelState extends ConsumerState<SubjectSel> {
  @override
  Widget build(BuildContext context) {
    final myBranches = ref.watch(selectedBranchs);
    return Container(
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 37, 37, 37),
        border: Border.all(
          color: Colors.white38,
          width: 2,
        ),
      ),
      child: Column(
        children: <Widget>[
          if (myBranches.isNotEmpty)
            TextButton(
              onPressed: () {
                showDialog(
                  builder: (context) {
                    return Material(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                        "Select Subject for ${widget.forYear}"),
                                    const CloseButton(),
                                  ],
                                ),
                                subProvidingYear(
                                  myBranches: myBranches,
                                  widget: widget,
                                  selectedYear: widget.selectedYear,
                                ),
                              ],
                            ),
                            TextButton(
                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(
                                    Color.fromARGB(255, 37, 37, 37),
                                  ),
                                  foregroundColor:
                                      MaterialStateProperty.all(Colors.white),
                                ),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text("Confirm")),
                          ],
                        ),
                      ),
                    );
                  },
                  context: context,
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Show Subjects for ${widget.forYear}",
                    style: const TextStyle(color: Colors.white),
                  ),
                  const Icon(
                    Icons.arrow_right_rounded,
                    color: Colors.white,
                  )
                ],
              ),
            ),
          ref.watch(widget.selectedYear).isEmpty
              ? Container(
                  padding: const EdgeInsets.all(10),
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    "",
                    style: TextStyle(color: Color.fromARGB(255, 37, 37, 37)),
                  ))
              : Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(color: Colors.grey.shade100),
                    child: ListOfSubs(selectedYear: widget.selectedYear),
                  ),
                ),
        ],
      ),
    );
  }
}

class ListOfSubs extends ConsumerWidget {
  final StateProvider<List<String>> selectedYear;
  const ListOfSubs({super.key, required this.selectedYear});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subs = ref.watch(selectedYear);
    return ListView.builder(
      shrinkWrap: true,
      itemCount: subs.length,
      itemBuilder: ((context, index) {
        final prpSubjects = subs[index];
        return Card(child: Text(prpSubjects));
      }),
    );
  }
}

class subProvidingYear extends StatelessWidget {
  final StateProvider<List<String>> selectedYear;
  const subProvidingYear({
    Key? key,
    required this.myBranches,
    required this.widget,
    required this.selectedYear,
  }) : super(key: key);

  final List<String> myBranches;
  final SubjectSel widget;

  @override
  Widget build(BuildContext context) {
    return SubjectYear(
      myBranches: myBranches,
      forYear: widget.forYear,
      selectedYear: widget.selectedYear,
    );
  }
}

List<String>? myYears(WidgetRef ref) {
  List<String> tempList = [];
  var allYear = ref.watch(yearList);
  final firstYear = ref.watch(year1);
  final secondYear = ref.watch(year2);
  final thirdYear = ref.watch(year3);
  final fourthYear = ref.watch(year4);

  if (firstYear.isNotEmpty) {
    tempList.add("First Year");
    ref.watch(yearList.notifier).update((state) => tempList);
  }
  if (secondYear.isNotEmpty) {
    tempList.add("Second Year");
    ref.watch(yearList.notifier).update((state) => tempList);
  }
  if (thirdYear.isNotEmpty) {
    tempList.add("Third Year");
    ref.watch(yearList.notifier).update((state) => tempList);
  }
  if (fourthYear.isNotEmpty) {
    tempList.add("Fourth Year");
    ref.watch(yearList.notifier).update((state) => tempList);
  }
  print(tempList);
  print(allYear);
  return tempList;
}
