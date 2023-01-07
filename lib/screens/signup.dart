import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cms/main.dart';
import 'package:cms/screens/Student/studentHome.dart';
import 'package:cms/screens/teacher_signup.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:riverpod/riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';
import 'login.dart';

final showDse = StateProvider<bool>((ref) {
  return false;
});
final isDSEStudent = StateProvider<bool>((ref) {
  return false;
});
final currentYear = StateProvider<String>((ref) {
  return "First Year";
});

class ForDse extends ConsumerWidget {
  const ForDse({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedYear = ref.watch(currentYear);
    var years = ['First Year', 'Second Year', 'Third Year', 'Fourth Year'];

    return Column(
      children: [
        const Text("Select Year"),
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
              value: selectedYear,
              disabledHint: const Text("Select year"),
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
              items: years.map((String year) {
                return DropdownMenuItem(
                  value: year,
                  child: Text(currentYear.name ?? year),
                );
              }).toList(),
              // After selecting the desired option,it will
              onChanged: (String? newValue) {
                if (newValue != null && newValue.isNotEmpty) {
                  ref.read(currentYear.notifier).update((state) => newValue);
                }

                ref.read(showDse.notifier).update((state) {
                  return newValue == "Second Year" ? true : false;
                });
              },
              hint: const Text("Select Year"),
            ),
          ),
        ),
      ],
    );
  }
}

final currentSelection = StateProvider<String>((ref) {
  return "No";
});
Widget showDSEText(WidgetRef ref) {
  final isDSE = ref.watch(showDse);
  final choice = ref.watch(currentSelection);
  return isDSE
      ? Column(
          children: [
            Text("Are you from DSE?"),
            RadioListTile(
                title: Text("Yes"),
                value: "Yes",
                groupValue: choice,
                onChanged: (value) {
                  ref.watch(currentSelection.notifier).update((state) {
                    return value.toString();
                  });
                  ref.watch(isDSEStudent.notifier).update((state) => true);
                }),
            RadioListTile(
                title: Text("No"),
                value: "No",
                groupValue: choice,
                onChanged: (value) {
                  ref.watch(currentSelection.notifier).update((state) {
                    return value.toString();
                  });
                  ref.watch(isDSEStudent.notifier).update((state) => false);
                }),
          ],
        )
      : Container();
}

// ignore: camel_case_types
class registration extends ConsumerStatefulWidget {
  const registration({Key? key}) : super(key: key);

  @override
  ConsumerState<registration> createState() => _registrationState();
}

// ignore: camel_case_types
class _registrationState extends ConsumerState<registration> {
  final _auth = FirebaseAuth.instance;
  bool _isLoading = false;
  SharedPreferences? loginData;
  String? errorMessage;
  final _formKey = GlobalKey<FormState>();
  final firstNameEditingController = TextEditingController();
  final rollNoEditingController = TextEditingController();
  final lastNameEditingController = TextEditingController();
  final emailEditingController = TextEditingController();
  final passwordEditingController = TextEditingController();
  final confirmPasswordEditingController = TextEditingController();
  String dropdownvalue = 'Civil Engineering';

  var branch = [
    'Artificial Intelligence & Data Science',
    'Civil Engineering',
    'Computer Engineering',
    'Electrical Engineering',
    'Electronics Engineering',
    'Information Technology',
    'Mechanical Engineering'
  ];
  Widget bracnchSelection() {
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
              disabledHint: const Text("Choose Collge"),
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
                setState(() {
                  dropdownvalue = newValue!;
                });
              },
              hint: const Text("Select College"),
            ),
          ),
        ),
      ],
    );
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
    final rollNofield = TextFormField(
      autofocus: false,
      controller: rollNoEditingController,
      keyboardType: TextInputType.text,
      validator: (value) {
        final con =
            value?.trim().toUpperCase().contains(RegExp(r'^[a-zA-Z]\d{3}$'));

        if (value!.isEmpty) {
          return ("roll No is required");
        }
        if (con != null && con == false) {
          return ("Enter valid roll no Ex B375");
        }
        return null;
      },
      onSaved: (value) {
        rollNoEditingController.text = value!;
      },
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
          prefixIcon: const Icon(Icons.numbers),
          contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
          hintText: "Roll No",
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
            signUp(emailEditingController.text, passwordEditingController.text);
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
                  bracnchSelection(),
                  const SizedBox(
                    height: 15,
                  ),
                  const ForDse(),
                  showDSEText(ref),
                  const SizedBox(height: 20),
                  rollNofield,
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
                                  builder: (contex) => const TeacherSignup()));
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

  void signUp(String email, String password) async {
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

  postDetailsToFirestore(WidgetRef ref) async {
    FirebaseFirestore firebaseFireStore = FirebaseFirestore.instance;
    User? user = _auth.currentUser;
    StudentModel userModel = StudentModel();
    final selectedYear = ref.watch(currentYear);
    final isDse = ref.watch(isDSEStudent);
    userModel.email = user?.email;

    userModel.uid = user?.uid;
    userModel.firstName = firstNameEditingController.text;
    userModel.lastName = lastNameEditingController.text;
    userModel.branch = dropdownvalue;
    userModel.rollNo = rollNoEditingController.text.toUpperCase();
    userModel.currentYear = selectedYear;
    userModel.isDse = isDse;
    await firebaseFireStore
        .collection("students")
        .doc(user?.uid)
        .set(userModel.toMap());
    Fluttertoast.showToast(msg: "Account Created Successfully");
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isLoggedIn', true);
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => StudentHomePage()),
        (route) => false);
  }
}
