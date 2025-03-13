import 'package:flutter/material.dart';
import 'launch_page/intro_page.dart';
import 'package:lbrikol/auth/login.dart';
import 'package:lbrikol/auth/register.dart';
import 'package:lbrikol/student_form/academic_info.dart';
import 'package:lbrikol/student_form/skills_services.dart';
import 'package:lbrikol/student_form/basic_info_student.dart';
import 'package:lbrikol/student_interfaces/home_page_gigs.dart';

// The home page will be first run
void main() {
  runApp(const MyApp());
}

class Lbrikol extends StatefulWidget {
  const Lbrikol({super.key});

  @override
  State<Lbrikol> createState() => _LbrikolState();
}

class _LbrikolState extends State<Lbrikol> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      home: const AcademicInformationScreen(),
      routes: {
        '/intro': (context) => const OnboardingScreen(), // Keep original
        '/login': (context) => LogInPage(), // Corrected from LoginScreen
        '/register': (context) => const RegisterPage(), // Corrected from RegisterScreen
        '/basicInfoStudent': (context) => const BasicInfoStudentPage(), // Corrected from BasicInfoStudentScreen
        '/academicInfo': (context) => const AcademicInformationScreen(),
        '/skillsServices': (context) => const SkillsAndServicesScreen(),
        '/home': (context) => const MainScreen(), // Ensure this class exists
      },
    );
  }
}









