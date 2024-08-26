import 'package:cms/screens/Student/studentHome.dart';
import 'package:cms/screens/Teacher/home.dart';
import 'package:cms/screens/login.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  final prefs = await SharedPreferences.getInstance();
  final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  final isTeacher = prefs.getBool('isTeacher') ?? false;
  runApp(ProviderScope(
      child: MyApp(
    isLoggedIn: isLoggedIn,
    isTeacher: isTeacher,
  )));
}

// Future initialization(BuildContext? context) async {
//   await Future.delayed(Duration(seconds: 3));
// }

class MyApp extends ConsumerWidget {
  final bool isLoggedIn;
  final bool isTeacher;
  const MyApp({super.key, required this.isLoggedIn, required this.isTeacher});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themMode = ref.watch(themeModeProvider);

    Widget routeLogin(bool login, bool isTeacher) {
      if (login) {
        if (isTeacher) {
          return const TeacherHome();
        } else {
          return const StudentHomePage();
        }
      }
      return const LoginScreen();
    }

    return MaterialApp(
      home: routeLogin(isLoggedIn, isTeacher),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.light(),
        useMaterial3: true,
        textTheme: GoogleFonts.nunitoTextTheme(Theme.of(context).textTheme),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.dark(),
        textTheme: GoogleFonts.nunitoTextTheme(Theme.of(context).textTheme),
      ),
      themeMode: themMode,
    );
  }
}

final themeModeProvider = StateProvider<ThemeMode>((ref) {
  return ThemeMode.light;
});
