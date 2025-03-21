import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lbricool/pages/auth/login.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();


  runApp(const Lbrikol());
}

class Lbrikol extends StatefulWidget {
  const Lbrikol({super.key});

  @override
  State<Lbrikol> createState() => _LbrikolState();
}

class _LbrikolState extends State<Lbrikol> {
  Widget? _homeScreen;

  @override
  void initState() {
    super.initState();
    _determineMainScreen();
  }



  Future<void> _determineMainScreen() async {
    setState(() {
      _homeScreen = LogInPage(); // Always go to login page
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: _homeScreen ?? const Scaffold(body: Center(child: CircularProgressIndicator())), // Show loading if still fetching role
    );
  }
}
