import 'dart:async';
import 'dart:io' show Platform;

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import 'dashboard_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with WidgetsBindingObserver {
  // final FirebaseAuth _auth = FirebaseAuth.instance;
  // final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // final GoogleSignIn _googleSignIn = GoogleSignIn();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _phoneOtpController = TextEditingController();

  bool _isEmailSent = false;
  bool _isPhoneOtpSent = false;
  bool _isEmailVerified = false;
  bool _isPhoneVerified = false;
  String? _verificationId;
  final bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  int _emailCooldown = 0;
  int _phoneCooldown = 0;
  Timer? _emailTimer;
  Timer? _phoneTimer;
  Timer? _verificationTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // _checkEmailVerification();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _emailTimer?.cancel();
    _phoneTimer?.cancel();
    _verificationTimer?.cancel();
    super.dispose();
  }

  void _startEmailCooldown() {
    setState(() => _emailCooldown = 60);
    _emailTimer?.cancel();
    _emailTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_emailCooldown > 0) {
        setState(() => _emailCooldown--);
      } else {
        timer.cancel();
      }
    });
  }

  void _startPhoneCooldown() {
    setState(() => _phoneCooldown = 60);
    _phoneTimer?.cancel();
    _phoneTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_phoneCooldown > 0) {
        setState(() => _phoneCooldown--);
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Reload user data when app returns to foreground
      // _checkEmailVerification();
    }
  }

  // Future<void> _checkEmailVerification() async {
  //   final user = FirebaseAuth.instance.currentUser;
  //   if (user != null) {
  //     await user.reload(); // Reload user state from Firebase
  //     setState(() => _isEmailVerified = user.emailVerified);
  //   }
  // }

/*
  Future<void> _sendEmailVerification() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email address')),
      );
      return;
    }

    if (password.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter a password')));
      return;
    }

    try {
      // Create a temporary user with Firebase Authentication
      final UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      // Send email verification using Firebase's default method
      await userCredential.user!.sendEmailVerification();

      setState(() => _isEmailSent = true);
      _startEmailCooldown();

      // Start a timer to periodically check if the email is verified
      _verificationTimer?.cancel();
      _verificationTimer = Timer.periodic(const Duration(seconds: 3), (
        timer,
      ) async {
        await userCredential.user!.reload(); // Reload user state
        if (userCredential.user!.emailVerified) {
          setState(() => _isEmailVerified = true);
          timer.cancel(); // Stop checking once verified
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Email successfully verified!')),
          );
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Verification email sent successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sending verification email: $e')),
      );
    }
  }
*/

/*
  Future<void> _sendPhoneOtp(String phone) async {
    if (phone.isEmpty || phone.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid phone number')),
      );
      return;
    }

    await _auth.verifyPhoneNumber(
      phoneNumber: '+91$phone',
      verificationCompleted: (PhoneAuthCredential credential) async {},
      verificationFailed: (FirebaseAuthException e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.message}')));
      },
      codeSent: (String verificationId, int? resendToken) {
        setState(() {
          _verificationId = verificationId;
          _isPhoneOtpSent = true;
        });
        _startPhoneCooldown();
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        setState(() => _verificationId = verificationId);
      },
    );
  }
*/

/*
  Future<void> _verifyPhoneOtp(String otp) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: otp,
      );
      setState(() => _isPhoneVerified = true);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Invalid OTP')));
    }
  }
*/

  Future<void> _signupUser(BuildContext context) async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (name.isEmpty ||
        email.isEmpty ||
        phone.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All fields are mandatory.')),
      );
      return;
    }

    if (!_isEmailVerified) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please verify your email first.')),
      );
      return;
    }

    if (!_isPhoneVerified) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please verify your phone number first.')),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Passwords do not match.')));
      return;
    }

    if (password.length < 8 ||
        !password.contains(RegExp(r'[A-Z]')) ||
        !password.contains(RegExp(r'[a-z]')) ||
        !password.contains(RegExp(r'[0-9]')) ||
        !password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]')) ||
        password.contains(' ')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Password must be at least 8 characters long, contain uppercase and lowercase letters, a number, a special character, and no spaces.',
          ),
        ),
      );
      return;
    }

    /*try {
      // Register the user in Firestore or your backend
      final user = FirebaseAuth.instance.currentUser;

      await FirebaseFirestore.instance.collection('users').doc(user!.uid).set({
        'name': name,
        'email': user.email,
        'phone': phone,
        'hasSetPassword': true, // Added this field
        'createdAt': FieldValue.serverTimestamp(),
        'emailVerified': true,
        'phoneVerified': true,
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder:
              (context) => DashboardScreen(fullName: name, phoneNumber: phone),
        ),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating account: ${e.message}')),
      );
    }*/
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Sign Up'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Stack(
              alignment: Alignment.centerRight,
              children: [
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                if (!_isEmailVerified)
                  Positioned(
                    right: 8,
                    child: ElevatedButton(
                      onPressed:
                          (_isEmailSent && _emailCooldown > 0)
                              ? null
                              : () => {}/*sendEmailVerification()*/,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            (_isEmailSent && _emailCooldown > 0)
                                ? Colors.grey
                                : Colors.blue,
                        foregroundColor:
                            (_isEmailSent && _emailCooldown > 0)
                                ? Colors.black
                                : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      child: Text(
                        _isEmailSent
                            ? (_emailCooldown > 0
                                ? 'Resend in $_emailCooldown'
                                : 'Resend')
                            : 'Verify',
                      ),
                    ),
                  ),
                if (_isEmailVerified)
                  const Positioned(
                    right: 8,
                    child: Icon(Icons.check_circle, color: Colors.green),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Stack(
              alignment: Alignment.centerRight,
              children: [
                TextField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                if (!_isPhoneVerified)
                  Positioned(
                    right: 8,
                    child: ElevatedButton(
                      onPressed:
                          (_isPhoneOtpSent && _phoneCooldown > 0)
                              ? null
                              : () => {}/*_sendPhoneOtp(_phoneController.text)*/,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            (_isPhoneOtpSent && _phoneCooldown > 0)
                                ? Colors.grey
                                : Colors.blue,
                        foregroundColor:
                            (_isPhoneOtpSent && _phoneCooldown > 0)
                                ? Colors.black
                                : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      child: Text(
                        _isPhoneOtpSent
                            ? (_phoneCooldown > 0
                                ? 'Resend in $_phoneCooldown'
                                : 'Resend')
                            : 'Send OTP',
                      ),
                    ),
                  ),
                if (_isPhoneVerified)
                  const Positioned(
                    right: 8,
                    child: Icon(Icons.check_circle, color: Colors.green),
                  ),
              ],
            ),
            if (_isPhoneOtpSent && !_isPhoneVerified) ...[
              const SizedBox(height: 16),
              TextField(
                controller: _phoneOtpController,
                decoration: const InputDecoration(
                  labelText: 'Phone OTP',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => {}/*_verifyPhoneOtp(_phoneOtpController.text)*/,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
                child: const Text('Verify OTP'),
              ),
            ],
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: !_isPasswordVisible,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _confirmPasswordController,
              obscureText: !_isConfirmPasswordVisible,
              decoration: InputDecoration(
                labelText: 'Confirm Password',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isConfirmPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed:
                      () => setState(
                        () =>
                            _isConfirmPasswordVisible =
                                !_isConfirmPasswordVisible,
                      ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => _signupUser(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Sign Up'),
            ),
            const SizedBox(height: 16),
            const Text('Or sign up with:', textAlign: TextAlign.center),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => {}/*_signInWithGoogle(context)*/,
                  icon: Image.asset(
                    'assets/images/google_logo.png',
                    height: 24,
                  ),
                  label: const Text('Google'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                  ),
                ),
                if (Platform.isIOS || Platform.isMacOS)
                  ElevatedButton.icon(
                    onPressed: () => {}/*_signInWithApple(context)*/,
                    icon: const Icon(Icons.apple),
                    label: const Text('Apple'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

/*
  Future<void> _signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleAuth =
          await googleUser!.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );

      if (userCredential.user != null) {
        // Set hasSetPassword to false for Google sign-in users
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'hasSetPassword': false, // Add this field
          'email': userCredential.user!.email,
          'name': userCredential.user!.displayName,
        }, SetOptions(merge: true));

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (context) => DashboardScreen(
                  fullName: userCredential.user!.displayName ?? 'User',
                  phoneNumber: userCredential.user!.phoneNumber ?? '',
                ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error signing in with Google: $e')),
      );
    }
  }
*/

/*
  Future<void> _signInWithApple(BuildContext context) async {
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final OAuthCredential credential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );
      if (userCredential.user != null) {
        // Set hasSetPassword to false for Apple sign-in users
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'hasSetPassword': false, // Add this field
          'email': userCredential.user!.email,
          'name':
              '${appleCredential.givenName ?? ''} ${appleCredential.familyName ?? ''}',
        }, SetOptions(merge: true));

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (context) => DashboardScreen(
                  fullName:
                      '${appleCredential.givenName ?? ''} ${appleCredential.familyName ?? ''}',
                  phoneNumber: userCredential.user!.phoneNumber ?? '',
                ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error signing in with Apple: $e')),
      );
    }
  }
*/
}

class EmailVerificationScreen extends StatefulWidget {
  final String email;
  final String name;
  final String phone;

  const EmailVerificationScreen({
    super.key,
    required this.email,
    required this.name,
    required this.phone,
  });

  @override
  _EmailVerificationScreenState createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  // final FirebaseAuth _auth = FirebaseAuth.instance;
  Timer? _verificationTimer;

  @override
  void initState() {
    super.initState();
    // _startVerificationCheck();
  }

/*
  void _startVerificationCheck() {
    _verificationTimer = Timer.periodic(const Duration(seconds: 1), (
      timer,
    ) async {
      await _auth.currentUser?.reload();
      if ((_auth.currentUser?.emailVerified ?? false) && mounted) {
        timer.cancel();
        Navigator.pop(context);
      }
    });
  }
*/

  @override
  void dispose() {
    _verificationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Email'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.email, size: 80, color: Colors.blue),
            const SizedBox(height: 20),
            Text('Verification link sent to ${widget.email}'),
            const SizedBox(height: 20),
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Return to Sign Up'),
            ),
          ],
        ),
      ),
    );
  }
}
