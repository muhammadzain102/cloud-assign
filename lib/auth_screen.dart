import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'homepage.dart';

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool isLogin = true;

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showMessage('Both email aur password are necessary');
      return;
    }

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePage()));
    } on FirebaseAuthException catch (e) {
      _showMessage('Login Error: ${e.message}');
    }
  }

  Future<void> _signUp() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showMessage('Both email aur password are necessary');
      return;
    }

    if (password.length < 6) {
      _showMessage('Password is of minimum 6 letter');
      return;
    }

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
      _showMessage('Account created successfully! Now login.');
      setState(() {
        isLogin = true;
      });
    } on FirebaseAuthException catch (e) {
      _showMessage('Signup Error: ${e.message}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Color(0xFF4A90E2); // Soft Blue
    final backgroundColor = Color(0xFFF5F7FA); // Light Background
    final cardColor = Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text(
          isLogin ? 'Login' : 'Sign Up',
          style: TextStyle(color: Colors.white), // Set the AppBar title color to white
        ),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 30),
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Icon(Icons.lock_outline, size: 60, color: primaryColor),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email, color: primaryColor),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock, color: primaryColor),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isLogin ? _login : _signUp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        padding: EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text(
                        isLogin ? 'Login' : 'Create Account',
                        style: TextStyle(color: Colors.white, fontSize: 16), // Set button text color to white
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        isLogin = !isLogin;
                        _emailController.clear();
                        _passwordController.clear();
                      });
                    },
                    child: Text(
                      isLogin
                          ? "Don't have an account? Create one"
                          : "Already have an account? Login",
                      style: TextStyle(color: primaryColor),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
