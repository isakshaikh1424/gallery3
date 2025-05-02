import 'dart:io';

import 'package:puluspatient/lib/screens/account_settings_screen.dart';
import 'package:puluspatient/lib/screens/edit_profile_screen.dart';
import 'package:puluspatient/lib/screens/password_screen.dart';
import 'package:puluspatient/lib/screens/payment_setting_screen.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // final FirebaseAuth _auth = FirebaseAuth.instance;
  // final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? _name;
  String? _email;
  String? _phone;
  String? _profilePictureUrl;
  bool? _isNewUser;

  @override
  void initState() {
    super.initState();
    // _loadUserProfile();
  }

  // Future<void> _loadUserProfile() async {
  //   final user = _auth.currentUser;
  //   if (user != null) {
  //     setState(() {
  //       _name = user.displayName;
  //       _email = user.email;
  //     });
  //
  //     await _fetchDetailsFromFirestore(user.uid);
  //   }
  // }

/*
  Future<void> _fetchDetailsFromFirestore(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final prefs = await SharedPreferences.getInstance();
      final user = _auth.currentUser!; // Add this line

      if (userDoc.exists) {
        final hasSetPassword = userDoc.data()?['hasSetPassword'] ?? false;
        setState(() {
          _isNewUser = !hasSetPassword;
          _name = userDoc.data()?['name'] ?? _name;
          _email = userDoc.data()?['email'] ?? _email;
          _phone = userDoc.data()?['phone'] ?? '';
          _profilePictureUrl =
              prefs.getString('profilePicture') ??
              userDoc.data()?['profilePictureUrl'] ??
              '';
        });
      } else {
        // ========= CRITICAL FIX STARTS =========
        // Determine password status from authentication providers
        final hasPasswordProvider = user.providerData.any(
          (info) => info.providerId == 'password',
        );

        await _firestore.collection('users').doc(userId).set({
          'hasSetPassword': hasPasswordProvider, // Set based on auth provider
          'createdAt': FieldValue.serverTimestamp(),
          'email': _email,
          'name': _name,
        });

        setState(() => _isNewUser = !hasPasswordProvider);
        // ========= CRITICAL FIX ENDS =========
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error fetching profile: $e')));
    }
  }
*/

  Future<void> _logout() async {
    // await _auth.signOut();
    Navigator.of(context).pushReplacementNamed('/login');
  }

  Widget _buildProfileImage() {
    if (_profilePictureUrl != null && _profilePictureUrl!.isNotEmpty) {
      return CircleAvatar(
        backgroundImage: FileImage(File(_profilePictureUrl!)),
        radius: 30,
      );
    } else {
      return CircleAvatar(
        backgroundColor: Colors.grey[500],
        radius: 30,
        child: Text(
          (_name?.isNotEmpty ?? false) ? _name![0].toUpperCase() : "U",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(''),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header Section
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white, // Additional safety for body background
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  _buildProfileImage(),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _name ?? '',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _email ?? '',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                        if (_phone != null && _phone!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              _phone!,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Your Profile Button
            ListTile(
              leading: const Icon(Icons.person, color: Colors.red),
              title: const Text('Your Profile', style: TextStyle(fontSize: 16)),
              trailing: const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey,
              ),
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => EditProfileScreen(
                          initialName: _name ?? '',
                          initialEmail: _email ?? '',
                          initialPhone: _phone ?? '',
                          initialProfilePicture: _profilePictureUrl ?? '',
                          onProfileUpdated: (String updatedPicture) async {
                            setState(() => _profilePictureUrl = updatedPicture);
                            final prefs = await SharedPreferences.getInstance();
                            await prefs.setString(
                              'profilePicture',
                              updatedPicture,
                            );
                          },
                        ),
                  ),
                );
                // await _loadUserProfile(); // Refresh after returning
              },
            ),
            const Divider(),

            // Password Button
            ListTile(
              leading: const Icon(Icons.lock, color: Colors.red),
              title: Text(
                _isNewUser == true ? 'Set Password' : 'Update Password',
                style: const TextStyle(fontSize: 16),
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey,
              ),
              onTap: () async {
                if (_isNewUser != null) {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => PasswordScreen(isNewUser: _isNewUser!),
                    ),
                  );

                  if (result == true) {
                    // await _loadUserProfile(); // Refresh after password change
                  }
                }
              },
            ),

            const Divider(),

            // Payment Settings Button
            ListTile(
              leading: const Icon(Icons.payment, color: Colors.red),
              title: const Text(
                'Payment Settings',
                style: TextStyle(fontSize: 16),
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey,
              ),
              onTap: () {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) => const PaymentSettingsScreen(),
                //   ),
                // );
              },
            ),

            const Divider(),

            // Account Settings Button
            ListTile(
              leading: const Icon(Icons.settings, color: Colors.red),
              title: const Text(
                'Account Settings',
                style: TextStyle(fontSize: 16),
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey,
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AccountSettingsScreen(),
                  ),
                );
              },
            ),

            const Divider(),
            // Logout Button
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout', style: TextStyle(fontSize: 16)),
              trailing: const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey,
              ),
              onTap: _logout,
            ),
          ],
        ),
      ),
    );
  }
}
