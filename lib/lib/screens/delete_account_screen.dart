// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DeleteAccountScreen extends StatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  _DeleteAccountScreenState createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _showPassword = false;
  // final FirebaseAuth _auth = FirebaseAuth.instance;
  // final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  // Future<void> _deleteAccount() async {
  //   if (_passwordController.text.isEmpty) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('Please enter your password')),
  //     );
  //     return;
  //   }
  //
  //   setState(() {
  //     _isLoading = true;
  //   });
  //
  //   try {
  //     User? user = _auth.currentUser;
  //     if (user == null) {
  //       throw Exception('No user currently signed in');
  //     }
  //
  //     // Get authentication providers for the current user
  //     List<String> providers = await _auth.fetchSignInMethodsForEmail(
  //       user.email ?? '',
  //     );
  //
  //     if (providers.contains('password')) {
  //       // Re-authenticate with email and password
  //       AuthCredential credential = EmailAuthProvider.credential(
  //         email: user.email!,
  //         password: _passwordController.text,
  //       );
  //       await user.reauthenticateWithCredential(credential);
  //     } else if (providers.contains('google.com')) {
  //       // For Google sign-in, we need to use a different approach
  //       // Show message to user that they need to re-authenticate with Google
  //       setState(() {
  //         _isLoading = false;
  //       });
  //       _showGoogleReauthDialog();
  //       return;
  //     }
  //
  //     // Delete user data from Firestore
  //     await _firestore.collection('users').doc(user.uid).delete();
  //
  //     // Delete user authentication account
  //     await user.delete();
  //
  //     setState(() {
  //       _isLoading = false;
  //     });
  //
  //     // Show success message and navigate to login screen
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text('Account deleted successfully')),
  //       );
  //       // Navigate to login screen and clear all previous routes
  //       Navigator.of(
  //         context,
  //       ).pushNamedAndRemoveUntil('/login', (route) => false);
  //     }
  //   } catch (e) {
  //     setState(() {
  //       _isLoading = false;
  //     });
  //
  //     String errorMessage = 'Failed to delete account';
  //     if (e is FirebaseAuthException) {
  //       if (e.code == 'requires-recent-login') {
  //         errorMessage =
  //             'Please sign out and sign in again before deleting your account';
  //       } else if (e.code == 'wrong-password') {
  //         errorMessage = 'Incorrect password';
  //       }
  //     }
  //
  //     if (mounted) {
  //       ScaffoldMessenger.of(
  //         context,
  //       ).showSnackBar(SnackBar(content: Text(errorMessage)));
  //     }
  //   }
  // }

  void _showGoogleReauthDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Re-authenticate Required'),
          content: const Text(
            'To delete your Google-linked account, you need to sign out and sign in again. '
            'After signing back in, try deleting your account again.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // _logout();
              },
              child: const Text('Sign Out Now'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  // Future<void> _logout() async {
  //   await _auth.signOut();
  //   if (mounted) {
  //     Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Delete Account'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Delete Your Account',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Warning: This action cannot be undone. Once your account is deleted, all your personal data will be permanently removed.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'What happens when you delete your account:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text('• All your personal information will be deleted'),
            const Text(
              '• Your account details will be removed from our system',
            ),
            const Text('• You will lose access to all your account data'),
            const SizedBox(height: 24),
            const Text(
              'To confirm deletion, please enter your password:',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passwordController,
              obscureText: !_showPassword,
              decoration: InputDecoration(
                hintText: 'Password',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    _showPassword ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _showPassword = !_showPassword;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : null/*_deleteAccount*/,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child:
                    _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                          'Permanently Delete Account',
                          style: TextStyle(fontSize: 16),
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
