import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart'
    as MyAuthProvider; // Alias for your AuthProvider
import 'package:shared_preferences/shared_preferences.dart';
import 'package:balloon_pop/providers/theme_provider.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  String email = '';
  String password = '';
  bool rememberMe = false; // Track the state of the "Remember Me" checkbox

  bool isLoading = false;
  String errorMessage = '';
  String resetMessage = '';

  @override
  void initState() {
    super.initState();
    _loadRememberedUser();
  }

  Future<void> _loadRememberedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('email') ?? '';
    final savedPassword = prefs.getString('password') ?? '';
    final savedRememberMe = prefs.getBool('rememberMe') ?? false;

    if (savedRememberMe) {
      setState(() {
        email = savedEmail;
        password = savedPassword;
        rememberMe = savedRememberMe;
      });
    }
  }

  void login() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        isLoading = true;
      });

      final authProvider =
          Provider.of<MyAuthProvider.AuthProvider>(context, listen: false);

      try {
        await authProvider.signIn(email, password);

        if (rememberMe) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('email', email);
          await prefs.setString('password', password);
          await prefs.setBool('rememberMe', rememberMe);
        } else {
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove('email');
          await prefs.remove('password');
          await prefs.remove('rememberMe');
        }

        Navigator.pushReplacementNamed(context, '/home');
      } on FirebaseAuthException catch (e) {
        setState(() {
          errorMessage = e.message ?? 'Something went wrong';
        });
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void resetPassword() async {
    if (email.isEmpty || !email.contains('@')) {
      setState(() {
        resetMessage = 'Please enter a valid email address to reset password';
      });
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      setState(() {
        resetMessage = 'Password reset link sent! Check your email.';
      });
    } on FirebaseAuthException catch (e) {
      setState(() {
        resetMessage = e.message ?? 'Error sending password reset email';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    bool isNightMode = themeProvider.isNightMode;

    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              isNightMode
                  ? 'assets/images/dark/sky_dark_1.png'
                  : 'assets/images/light/sky_1.png',
              fit: BoxFit.cover,
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Login',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 20),
                      _buildTextField(
                        labelText: 'Email',
                        icon: Icons.email,
                        onChanged: (value) {
                          setState(() {
                            email = value;
                          });
                        },
                        validator: (value) =>
                            value == null || !value.contains('@')
                                ? 'Enter a valid email'
                                : null,
                        initialValue: email, // Load saved email
                      ),
                      SizedBox(height: 20),
                      _buildTextField(
                        labelText: 'Password',
                        icon: Icons.lock,
                        obscureText: true,
                        onChanged: (value) {
                          setState(() {
                            password = value;
                          });
                        },
                        validator: (value) => value == null || value.length < 6
                            ? 'Password must be at least 6 characters'
                            : null,
                        initialValue: password, // Load saved password
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Checkbox(
                            value: rememberMe,
                            onChanged: (value) {
                              setState(() {
                                rememberMe = value ?? false;
                              });
                            },
                          ),
                          Text(
                            'Remember Me',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: resetPassword,
                          child: Text(
                            'Forgot Password?',
                            style: TextStyle(
                              color: Colors.orangeAccent,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      if (resetMessage.isNotEmpty)
                        Text(
                          resetMessage,
                          style: TextStyle(color: Colors.greenAccent),
                        ),
                      SizedBox(height: 10),
                      if (errorMessage.isNotEmpty)
                        Text(
                          errorMessage,
                          style: TextStyle(color: Colors.red),
                        ),
                      SizedBox(height: 20),
                      isLoading
                          ? CircularProgressIndicator()
                          : ElevatedButton(
                              onPressed: login,
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                    vertical: 15, horizontal: 40),
                                backgroundColor:
                                    Colors.greenAccent, // Matching game theme
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              child: Text(
                                'Login',
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 40,
            left: 20,
            child: FloatingActionButton(
              backgroundColor: Colors.orangeAccent,
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/signup');
              },
              child: Icon(Icons.arrow_back, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String labelText,
    required IconData icon,
    required Function(String) onChanged,
    required String? Function(String?)? validator,
    bool obscureText = false,
    String? initialValue,
  }) {
    return TextFormField(
      onChanged: onChanged,
      validator: validator,
      obscureText: obscureText,
      style: TextStyle(color: Colors.white),
      initialValue: initialValue,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(icon, color: Colors.white),
        filled: true,
        fillColor: Colors.white.withOpacity(0.2),
        labelStyle: TextStyle(color: Colors.white),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: Colors.white),
        ),
      ),
    );
  }
}
