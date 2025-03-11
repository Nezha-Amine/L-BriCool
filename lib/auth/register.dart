import 'package:flutter/material.dart';
import 'package:lbrikol/auth/login.dart';
import 'package:lbrikol/after_auth/welcome_page.dart';

// Stateful widget for the registration page
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // Boolean variables to toggle password visibility
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // App bar with title and custom background color
      appBar: AppBar(
        backgroundColor: const Color(0xFF40189D),
        title: const Text(
          'L\'BriCool',
          style: TextStyle(
              fontSize: 25, fontWeight: FontWeight.w500, color: Colors.white),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              // Page heading
              const Text(
                "Create an Account",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              // Subheading
              const Text(
                "Please fill registration form below",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 25),
              // Email input field
              TextField(
                decoration: InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(27),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 22),
                ),
              ),
              const SizedBox(height: 15),
              // Password input field with visibility toggle
              TextField(
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: "Password",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(27),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 22),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: const Color(0xFF40189D),
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 15),
              // Confirm password input field with visibility toggle
              TextField(
                obscureText: _obscureConfirmPassword,
                decoration: InputDecoration(
                  labelText: "Confirm Password",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(27),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 22),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureConfirmPassword
                        ? Icons.visibility_off
                        : Icons.visibility),
                    color: const Color(0xFF40189D),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Sign up button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF40189D),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(27),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  onPressed: () {
                    // TODO: Implement signup logic and database interaction before navigating to the home page
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const WelcomePage(),
                      ),
                    );
                  },
                  child: const Text("SIGN UP",
                      style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 15),
              // Terms and conditions text
              Center(
                child: RichText(
                  text: const TextSpan(
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                    children: [
                      TextSpan(text: 'By tapping "Sign Up", you accept our '),
                      TextSpan(
                        text: 'terms',
                        style: TextStyle(
                          color: Color(0xFF40189D),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(text: ' and '),
                      TextSpan(
                        text: 'conditions',
                        style: TextStyle(
                          color: Color(0xFF40189D),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Column(
                children: [
                  // Divider for separation
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Divider(
                      color: Colors.grey.shade300,
                      thickness: 1,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Text prompting user to login
                  const Text(
                    "Already have an account?",
                    style: TextStyle(fontSize: 14, color: Colors.black),
                  ),
                  const SizedBox(height: 10),
                  // Login button
                  SizedBox(
                    width: 250,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE1D3FF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: () {
                        // The button navigates to the login page
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => LogInPage()),
                        );
                      },
                      child: const Text(
                        "LOGIN",
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF40189D),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
