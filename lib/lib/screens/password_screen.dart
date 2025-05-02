// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PasswordScreen extends StatefulWidget {
  final bool isNewUser;

  const PasswordScreen({super.key, required this.isNewUser});

  @override
  _PasswordScreenState createState() => _PasswordScreenState();
}

class _PasswordScreenState extends State<PasswordScreen> {
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  String? _errorMessage;
  bool _isProcessing = false;

  void _toggleCurrentPasswordVisibility() =>
      setState(() => _obscureCurrentPassword = !_obscureCurrentPassword);
  void _toggleNewPasswordVisibility() =>
      setState(() => _obscureNewPassword = !_obscureNewPassword);
  void _toggleConfirmPasswordVisibility() =>
      setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);

  bool _isPasswordStrong(String password) {
    final regex = RegExp(
      r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$',
    );
    return regex.hasMatch(password);
  }

  // Future<void> _handlePasswordOperation() async {
  //   setState(() {
  //     _errorMessage = null;
  //     _isProcessing = true;
  //   });
  //
  //   try {
  //     // Validate passwords match
  //     if (_newPasswordController.text != _confirmPasswordController.text) {
  //       throw FirebaseAuthException(
  //         code: 'passwords-mismatch',
  //         message: 'Passwords do not match',
  //       );
  //     }
  //
  //     // Validate password strength
  //     if (!_isPasswordStrong(_newPasswordController.text)) {
  //       throw FirebaseAuthException(
  //         code: 'weak-password',
  //         message:
  //             'Password must be at least 8 characters with numbers and special characters',
  //       );
  //     }
  //
  //     final user = FirebaseAuth.instance.currentUser;
  //     if (user == null) {
  //       throw FirebaseAuthException(
  //         code: 'no-user',
  //         message: 'No authenticated user',
  //       );
  //     }
  //
  //     if (widget.isNewUser) {
  //       await user.updatePassword(_newPasswordController.text);
  //       await _updateUserDocument(user.uid, true); // Changed to true
  //     } else {
  //       // ... YOUR EXISTING REAUTHENTICATION CODE ...
  //       await user.updatePassword(_newPasswordController.text);
  //     }
  //
  //     // ADD THIS LINE FOR PASSWORD STATE UPDATE
  //     await _updateUserDocument(user.uid, true);
  //
  //     if (mounted) {
  //       Navigator.pop(context, true);
  //       _showSuccessSnackbar();
  //     }
  //   } on FirebaseAuthException catch (e) {
  //     _handleAuthError(e);
  //   } catch (e) {
  //     _handleGenericError(e);
  //   } finally {
  //     if (mounted) setState(() => _isProcessing = false);
  //   }
  // }

  // Future<void> _updateUserDocument(String uid, bool hasSetPassword) async {
  //   try {
  //     await FirebaseFirestore.instance.collection('users').doc(uid).set({
  //       'hasSetPassword': hasSetPassword, // Updates password status
  //       'changePassword': false, // Optional field for tracking password changes
  //       'lastPasswordUpdate':
  //           hasSetPassword
  //               ? FieldValue.serverTimestamp()
  //               : null, // Update timestamp only if password is set
  //     }, SetOptions(merge: true));
  //   } catch (e) {
  //     print('Error updating user document: $e');
  //   }
  // }

  void _showSuccessSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.isNewUser
              ? 'Password set successfully'
              : 'Password updated successfully',
        ),
        backgroundColor: Colors.green,
      ),
    );
  }

  // void _handleAuthError(FirebaseAuthException e) {
  //   setState(() {
  //     switch (e.code) {
  //       case 'wrong-password':
  //         _errorMessage = 'Current password is incorrect';
  //         break;
  //       case 'weak-password':
  //         _errorMessage =
  //             'Password too weak. Use 8+ characters with numbers and symbols';
  //         break;
  //       case 'requires-recent-login':
  //         _errorMessage = 'Session expired. Please re-authenticate';
  //         break;
  //       default:
  //         _errorMessage = e.message ?? 'Authentication error occurred';
  //     }
  //   });
  // }

  void _handleGenericError(dynamic e) {
    setState(() => _errorMessage = 'Operation failed: ${e.toString()}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(widget.isNewUser ? 'Set Password' : 'Update Password'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_errorMessage != null)
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            const SizedBox(height: 20),
            if (!widget.isNewUser) ...[
              TextField(
                controller: _currentPasswordController,
                decoration: InputDecoration(
                  labelText: 'Current Password',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureCurrentPassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: _toggleCurrentPasswordVisibility,
                  ),
                ),
                obscureText: _obscureCurrentPassword,
              ),
              const SizedBox(height: 16),
            ],
            TextField(
              controller: _newPasswordController,
              decoration: InputDecoration(
                labelText: 'New Password',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureNewPassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                  onPressed: _toggleNewPasswordVisibility,
                ),
              ),
              obscureText: _obscureNewPassword,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _confirmPasswordController,
              decoration: InputDecoration(
                labelText: 'Confirm New Password',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirmPassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                  onPressed: _toggleConfirmPasswordVisibility,
                ),
              ),
              obscureText: _obscureConfirmPassword,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isProcessing ? null : null/*_handlePasswordOperation*/,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isProcessing ? Colors.grey : Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                widget.isNewUser ? "Set Password" : "Update Password",
              ),
            ),
            if (_isProcessing) ...[
              const SizedBox(height: 16),
              const Center(child: CircularProgressIndicator()),
            ],
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
