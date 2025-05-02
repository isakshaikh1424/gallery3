import 'dart:async';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'dashboard_screen.dart';
import 'signup_screen.dart';

class LoginWithOTPScreen extends StatefulWidget {
  const LoginWithOTPScreen({super.key});

  @override
  _LoginWithOTPScreenState createState() => _LoginWithOTPScreenState();
}

class _LoginWithOTPScreenState extends State<LoginWithOTPScreen> {
  // final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  String? _verificationId;
  int? _resendToken;
  bool _isLoading = false;
  bool _isOtpSent = false;
  int _cooldownSeconds = 60;
  Timer? _cooldownTimer;

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    _cooldownTimer?.cancel();
    super.dispose();
  }

  // Future<bool> _checkPhoneNumberInDatabase(String phoneNumber) async {
  //   try {
  //     final snapshot =
  //         await FirebaseFirestore.instance
  //             .collection('users')
  //             .where('phone', isEqualTo: phoneNumber)
  //             .get();
  //     return snapshot.docs.isNotEmpty;
  //   } catch (e) {
  //     _showErrorSnackbar('Database error: ${e.toString()}');
  //     return false;
  //   }
  // }

  void _startCooldown() {
    _cooldownSeconds = 60;
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_cooldownSeconds > 0) {
        setState(() => _cooldownSeconds--);
      } else {
        timer.cancel();
        setState(() {});
      }
    });
  }

  // Future<void> _sendOTP() async {
  //   final phoneNumber = _phoneController.text.trim();
  //   if (phoneNumber.isEmpty || phoneNumber.length != 10) {
  //     _showErrorSnackbar('Please enter a valid 10-digit phone number');
  //     return;
  //   }
  //
  //   final formattedNumber = '+91$phoneNumber';
  //   setState(() => _isLoading = true);
  //
  //   try {
  //     final isRegistered = await _checkPhoneNumberInDatabase(formattedNumber);
  //     if (!isRegistered) {
  //       _showNotRegisteredDialog(formattedNumber);
  //       return;
  //     }
  //
  //     await _auth.verifyPhoneNumber(
  //       phoneNumber: formattedNumber,
  //       verificationCompleted: _handleAutoVerification,
  //       verificationFailed: _handleVerificationFailure,
  //       codeSent: _handleCodeSent,
  //       codeAutoRetrievalTimeout: _handleTimeout,
  //       forceResendingToken: _resendToken,
  //     );
  //   } on FirebaseAuthException catch (e) {
  //     _handleAuthError(e);
  //   } catch (e) {
  //     _showErrorSnackbar('Error: ${e.toString()}');
  //   } finally {
  //     if (mounted) setState(() => _isLoading = false);
  //   }
  // }

  Future<void> _resendOTP() async {
    _startCooldown();
    // await _sendOTP();
  }

  // Future<void> _verifyOTP() async {
  //   final otp = _otpController.text.trim();
  //   if (otp.isEmpty || _verificationId == null) {
  //     _showErrorSnackbar('Please enter the OTP');
  //     return;
  //   }
  //
  //   try {
  //     final credential = PhoneAuthProvider.credential(
  //       verificationId: _verificationId!,
  //       smsCode: otp,
  //     );
  //     await _handleSuccessfulLogin(credential);
  //   } on FirebaseAuthException catch (e) {
  //     _handleAuthError(e);
  //   }
  // }

  // Future<void> _handleAutoVerification(PhoneAuthCredential credential) async {
  //   await _handleSuccessfulLogin(credential);
  // }

  // Future<void> _handleSuccessfulLogin(PhoneAuthCredential credential) async {
  //   try {
  //     final userCredential = await _auth.signInWithCredential(credential);
  //     if (userCredential.user != null) {
  //       _navigateToDashboard(userCredential);
  //     }
  //   } on FirebaseAuthException catch (e) {
  //     _handleAuthError(e);
  //   }
  // }

  // void _navigateToDashboard(UserCredential userCredential) {
  //   Navigator.pushAndRemoveUntil(
  //     context,
  //     MaterialPageRoute(
  //       builder:
  //           (context) => PopScope(
  //             canPop: false,
  //             onPopInvokedWithResult: (didPop, Result) => SystemNavigator.pop(),
  //             child: DashboardScreen(
  //               fullName: userCredential.user!.displayName ?? 'User',
  //               phoneNumber: userCredential.user!.phoneNumber ?? '',
  //             ),
  //           ),
  //     ),
  //     (route) => false,
  //   );
  // }

  void _handleCodeSent(String verificationId, int? resendToken) {
    setState(() {
      _verificationId = verificationId;
      _resendToken = resendToken;
      _isOtpSent = true;
    });
    _startCooldown();
    _showSuccessSnackbar('OTP sent to +91${_phoneController.text}');
  }

  void _handleTimeout(String verificationId) {
    _verificationId = verificationId;
  }

  // void _handleVerificationFailure(FirebaseAuthException e) {
  //   _showErrorSnackbar('Verification failed: ${e.message}');
  // }
  //
  // void _handleAuthError(FirebaseAuthException e) {
  //   final message = switch (e.code) {
  //     'invalid-phone-number' => 'Invalid phone number format',
  //     'quota-exceeded' => 'SMS quota exceeded. Try again later',
  //     'too-many-requests' => 'Too many attempts. Please wait',
  //     'session-expired' => 'OTP expired. Request new code',
  //     'invalid-verification-code' => 'Invalid OTP entered',
  //     _ => 'Authentication error: ${e.message}',
  //   };
  //   _showErrorSnackbar(message);
  // }

  void _showNotRegisteredDialog(String phoneNumber) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Not Registered'),
            content: Text('$phoneNumber is not registered. Create an account?'),
            actions: [
              TextButton(
                onPressed: Navigator.of(context).pop,
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SignupScreen(),
                    ),
                  );
                },
                child: const Text('Sign Up'),
              ),
            ],
          ),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('OTP Login'),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
                hintText: 'Enter 10-digit number',
              ),
              keyboardType: TextInputType.phone,
              maxLength: 10,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : null/*_sendOTP*/,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child:
                  _isLoading
                      ? const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      )
                      : const Text('Send OTP'),
            ),
            if (_isOtpSent) ...[
              const SizedBox(height: 30),
              TextField(
                controller: _otpController,
                decoration: const InputDecoration(
                  labelText: 'Enter OTP',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock_clock),
                ),
                keyboardType: TextInputType.number,
                maxLength: 6,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: null/*_verifyOTP*/,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Verify OTP'),
              ),
              const SizedBox(height: 15),
              TextButton(
                onPressed: _cooldownSeconds > 0 ? null : _resendOTP,
                child: Text(
                  _cooldownSeconds > 0
                      ? 'Resend OTP in $_cooldownSeconds seconds'
                      : 'Resend OTP',
                  style: TextStyle(
                    color: _cooldownSeconds > 0 ? Colors.grey : Colors.red,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
