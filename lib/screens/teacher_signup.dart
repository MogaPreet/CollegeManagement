import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cms/models/user.dart';
import 'package:cms/screens/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:multi_select_flutter/bottom_sheet/multi_select_bottom_sheet_field.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:multi_select_flutter/util/multi_select_list_type.dart';

final selBranch = StateProvider<String>((ref) {
  return "COMPS";
});

class BranchSelction extends ConsumerWidget {
  const BranchSelction({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dropdownvalue = ref.watch(selBranch);

    var branch = ['COMPS', 'IT', 'EXTC', 'PLASTIC', 'CIVIL', 'CHEMICAL'];

    return Column(
      children: [
        const Text("Select Branch"),
        const SizedBox(
          height: 10,
        ),
        DecoratedBox(
          decoration: BoxDecoration(
              color: Colors.black, borderRadius: BorderRadius.circular(8)),
          child: Padding(
            padding: const EdgeInsets.only(left: 15, right: 15),
            child: DropdownButton(
              // Initial Value
              value: dropdownvalue,
              disabledHint: const Text("Select Branch"),
              style: const TextStyle(color: Colors.white),
              underline: Container(),
              borderRadius: BorderRadius.circular(2),
              isExpanded: true,
              dropdownColor: Colors.black,
              // Down Arrow Icon

              icon: const Icon(
                Icons.keyboard_arrow_down,
                color: Colors.white,
              ),

              // Array list of items
              items: branch.map((String branch) {
                return DropdownMenuItem(
                  value: branch,
                  child: Text(branch),
                );
              }).toList(),
              // After selecting the desired option,it will

              onChanged: (String? newValue) {
                if (newValue != null && newValue.isNotEmpty) {
                  ref.watch(selBranch.notifier).update((state) => newValue);
                }
              },
              hint: const Text("Select Branch"),
            ),
          ),
        ),
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
    final _items = theSubject()
        .map((subject) => MultiSelectItem<String>(subject, subject))
        .toList();
    List<String> selectedSubject = [];

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
            color: Colors.black,
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
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(.4),
                      border: Border.all(
                        color: Theme.of(context).primaryColor,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      children: <Widget>[
                        MultiSelectBottomSheetField(
                          initialChildSize: 0.4,
                          listType: MultiSelectListType.CHIP,
                          searchable: true,
                          buttonText: const Text("Select Subjects"),
                          title: const Text("Subjects"),
                          items: _items,
                          onConfirm: (values) {
                            selectedSubject = values.cast();
                            ref
                                .watch(selectedSubjects.notifier)
                                .update((state) => selectedSubject);
                          },
                          chipDisplay: MultiSelectChipDisplay(
                            onTap: (value) {
                              setState(() {
                                selectedSubject.remove(value);
                              });
                            },
                          ),
                        ),
                        ref.watch(selectedSubjects).isEmpty
                            ? Container(
                                padding: const EdgeInsets.all(10),
                                alignment: Alignment.centerLeft,
                                child: const Text(
                                  "None selected",
                                  style: TextStyle(color: Colors.black54),
                                ))
                            : Container(),
                      ],
                    ),
                  ),
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
          .createUserWithEmailAndPassword(email: email, password: password)
          .then((value) => {postDetailsToFirestore(ref)})
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
    final teacherBranch = ref.watch(selBranch);
    final selSub = ref.watch(selectedSubjects);
    teacherModel.email = user?.email;

    teacherModel.uid = user?.uid;
    teacherModel.firstName = firstNameEditingController.text;
    teacherModel.lastName = lastNameEditingController.text;
    teacherModel.branch = teacherBranch;
    teacherModel.classCoord = false;
    teacherModel.subject = selSub.toString();
    await firebaseFireStore
        .collection("teachers")
        .doc(user?.uid)
        .set(teacherModel.toMap());
    Fluttertoast.showToast(msg: "Account Created Successfully, Please Login");
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
        (route) => false);
  }
}