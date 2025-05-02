import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import 'forgot_password_screen.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailOrPhoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isEmail = false;

  @override
  void initState() {
    super.initState();
    _emailOrPhoneController.addListener(_checkInputType);
  }

  @override
  void dispose() {
    _emailOrPhoneController.removeListener(_checkInputType);
    _emailOrPhoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _checkInputType() {
    final text = _emailOrPhoneController.text;
    final newIsEmail = text.contains('@');
    if (newIsEmail != _isEmail) {
      setState(() {
        _isEmail = newIsEmail;
      });
    }
  }

  bool isEmail(String input) => input.contains('@');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 500),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Image.asset('assets/images/vaidyava.png', height: 100),
                      SizedBox(height: 20),
                      TextFormField(
                        controller: _emailOrPhoneController,
                        decoration: InputDecoration(
                          labelText: 'Email or Phone',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.email),
                        ),
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.next,
                        autocorrect: false,
                        enableSuggestions: false,
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                        ),
                        obscureText: !_isPasswordVisible,
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Clicked on Login")),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(double.infinity, 50),
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                        child: Text('Login'),
                      ),
                      SizedBox(height: 20),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ForgotPasswordScreen(),
                            ),
                          );
                        },
                        child: Text('Forgot Passwordsa?'),
                      ),
                      TextButton(
                        onPressed: () {
                          // OTP login logic
                        },
                        child: Text('Login with OTP'),
                      ),
                      SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(child: Divider(thickness: 1)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text('OR'),
                          ),
                          Expanded(child: Divider(thickness: 1)),
                        ],
                      ),
                      SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: () => {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          minimumSize: Size(double.infinity, 50),
                          side: BorderSide(color: Colors.grey),
                        ),
                        icon: Image.asset('assets/images/google_logo.png', height: 24),
                        label: Text('Sign in with Google'),
                      ),
                      if (!kIsWeb) ...[
                        SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: () => {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            minimumSize: Size(double.infinity, 50),
                          ),
                          icon: Icon(Icons.apple, color: Colors.white, size: 24),
                          label: Text('Sign in with Apple'),
                        ),
                      ],
                      SizedBox(height: 20),
                      TextButton(
                        onPressed: () {
                          // Sign-up navigation
                        },
                        child: Text('Don\'t have an account? Sign up'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
