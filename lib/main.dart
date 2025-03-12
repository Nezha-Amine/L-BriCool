import 'package:flutter/material.dart';
import 'launch_page/intro_page.dart';

// The home page will be first run
void main() {
  runApp(const Lbrikol());
}

class Lbrikol extends StatefulWidget {
  const Lbrikol({super.key});

  @override
  State<Lbrikol> createState() => _LbrikolState();
}

class _LbrikolState extends State<Lbrikol> {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}
