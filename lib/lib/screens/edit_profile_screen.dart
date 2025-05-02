import 'dart:async';
import 'dart:io';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditProfileScreen extends StatefulWidget {
  final String initialName;
  final String initialEmail;
  final String? initialPhone;
  final String? initialProfilePicture;
  final Function(String) onProfileUpdated;

  const EditProfileScreen({
    super.key,
    required this.initialName,
    required this.initialEmail,
    this.initialPhone,
    this.initialProfilePicture,
    required this.onProfileUpdated,
  });

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  // final FirebaseAuth _auth = FirebaseAuth.instance;
  // final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();
  final List<String> _genderOptions = const ['Male', 'Female', 'Other'];

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  String? _profileImageUrl = '';
  bool _isImageDeleted = false;
  String? _gender;
  DateTime? _dob;
  bool _isPhoneAdded = false;
  String? _verificationId;

  // New state variables to track changes and verification status
  bool _isEmailVerified = false;
  bool _isPhoneVerified = false;
  bool _isEmailChanged = false;
  bool _isPhoneChanged = false;
  bool _hasUnsavedChanges = false;

  // Cooldown timers
  late ValueNotifier<int> _emailCooldown;
  late ValueNotifier<int> _phoneCooldown;
  Timer? _emailCooldownTimer;
  Timer? _phoneCooldownTimer;

  String _originalEmail = '';
  String _originalPhone = '';
  String _pendingEmail = '';
  String _newPhone = '';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _emailController = TextEditingController(text: widget.initialEmail);
    _phoneController = TextEditingController(text: widget.initialPhone ?? '');
    _profileImageUrl = widget.initialProfilePicture;

    _emailCooldown = ValueNotifier(0);
    _phoneCooldown = ValueNotifier(0);

    _originalEmail = widget.initialEmail;
    _originalPhone = widget.initialPhone ?? '';

    // _loadUserProfile();
    // _loadAuthState();

    // Add listeners to detect changes in email and phone fields
    _emailController.addListener(_checkEmailChange);
    _phoneController.addListener(_checkPhoneChange);
  }

  @override
  void dispose() {
    _emailCooldown.dispose();
    _phoneCooldown.dispose();
    _emailCooldownTimer?.cancel();
    _phoneCooldownTimer?.cancel();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _checkEmailChange() {
    final newEmail = _emailController.text.trim();
    if (newEmail != _originalEmail) {
      if (!_isEmailChanged) {
        setState(() {
          _isEmailChanged = true;
          _isEmailVerified = false;
          _hasUnsavedChanges = true;
        });
      }
    } else {
      if (_isEmailChanged) {
        setState(() {
          _isEmailChanged = false;
          _isEmailVerified = true; // Original email is already verified
          _updateHasUnsavedChanges();
        });
      }
    }
  }

  void _checkPhoneChange() {
    final newPhone = _phoneController.text.trim();
    if (newPhone != _originalPhone) {
      if (!_isPhoneChanged) {
        setState(() {
          _isPhoneChanged = true;
          _isPhoneVerified = false;
          _hasUnsavedChanges = true;
        });
      }
    } else {
      if (_isPhoneChanged) {
        setState(() {
          _isPhoneChanged = false;
          _isPhoneVerified = _originalPhone.isEmpty ? false : true;
          _updateHasUnsavedChanges();
        });
      }
    }
  }

  void _updateHasUnsavedChanges() {
    setState(() {
      _hasUnsavedChanges =
          _isEmailChanged ||
          _isPhoneChanged ||
          _isImageDeleted ||
          (_profileImageUrl != widget.initialProfilePicture &&
              _profileImageUrl != null &&
              _profileImageUrl!.isNotEmpty) ||
          _gender != null ||
          _dob != null;
    });
  }

  // Future<void> _loadAuthState() async {
  //   final user = _auth.currentUser;
  //   if (user != null) {
  //     setState(() {
  //       _isEmailVerified = user.emailVerified;
  //     });
  //   }
  // }

  // Future<void> _loadUserProfile() async {
  //   try {
  //     final user = _auth.currentUser;
  //     if (user != null) {
  //       final userData =
  //           await _firestore.collection('users').doc(user.uid).get();
  //       if (userData.exists) {
  //         setState(() {
  //           _nameController.text =
  //               userData.data()?['name'] ?? widget.initialName;
  //           _emailController.text =
  //               userData.data()?['email'] ?? widget.initialEmail;
  //           _phoneController.text =
  //               userData.data()?['phone'] ?? widget.initialPhone ?? '';
  //           _profileImageUrl =
  //               userData.data()?['profilePictureUrl'] ??
  //               widget.initialProfilePicture ??
  //               '';
  //
  //           // Validate gender value
  //           final storedGender = userData.data()?['gender'];
  //           _gender =
  //               _genderOptions.contains(storedGender) ? storedGender : null;
  //
  //           // Handle date parsing
  //           final dobString = userData.data()?['dob'];
  //           _dob = _parseDate(dobString);
  //
  //           _isPhoneAdded = _phoneController.text.isNotEmpty;
  //
  //           // Update original values after loading
  //           _originalEmail = _emailController.text;
  //           _originalPhone = _phoneController.text;
  //
  //           // Set verification status for loaded values
  //           _isEmailVerified = true; // Assuming loaded email is verified
  //           _isPhoneVerified =
  //               _isPhoneAdded; // Assuming loaded phone is verified if present
  //         });
  //       }
  //     }
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Error loading profile data: ${e.toString()}')),
  //     );
  //     _resetToInitialValues();
  //   }
  // }

  DateTime? _parseDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return null;

    // Try ISO format first
    DateTime? date = DateTime.tryParse(dateString);
    if (date != null) return date;

    // Try common formats
    final formats = [
      DateFormat('dd/MM/yyyy'),
      DateFormat('MM/dd/yyyy'),
      DateFormat('yyyy-MM-dd'),
      DateFormat('dd-MM-yyyy'),
      DateFormat('yyyy/MM/dd'),
    ];

    for (var format in formats) {
      try {
        return format.parse(dateString);
      } catch (_) {}
    }
    return null;
  }

  void _resetToInitialValues() {
    setState(() {
      _nameController.text = widget.initialName;
      _emailController.text = widget.initialEmail;
      _phoneController.text = widget.initialPhone ?? '';
      _profileImageUrl = widget.initialProfilePicture ?? '';
      _gender = null;
      _dob = null;

      _originalEmail = widget.initialEmail;
      _originalPhone = widget.initialPhone ?? '';

      _isEmailChanged = false;
      _isPhoneChanged = false;
      _isEmailVerified = true; // Assuming original email is verified
      _isPhoneVerified =
          widget.initialPhone != null && widget.initialPhone!.isNotEmpty;
      _hasUnsavedChanges = false;
    });
  }

  Future<void> _uploadProfileImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image == null) return;

      setState(() {
        _profileImageUrl = image.path;
        _isImageDeleted = false;
        _hasUnsavedChanges = true;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading profile picture: $e')),
      );
    }
  }

  Future<void> _deleteProfileImage() async {
    try {
      setState(() {
        _profileImageUrl = '';
        _isImageDeleted = true;
        _hasUnsavedChanges = true;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Profile picture deleted')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting profile picture: $e')),
      );
    }
  }

  // Future<void> _verifyEmail() async {
  //   final newEmail = _emailController.text.trim();
  //   final user = _auth.currentUser;
  //
  //   if (newEmail.isEmpty ||
  //       !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(newEmail)) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('Please enter a valid email address')),
  //     );
  //     return;
  //   } else if (newEmail == user?.email) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('This is already your current email')),
  //     );
  //     return;
  //   }
  //
  //   try {
  //     setState(() => _pendingEmail = newEmail);
  //     await user?.verifyBeforeUpdateEmail(newEmail);
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(
  //         content: Text('Verification email sent. Please check your inbox.'),
  //       ),
  //     );
  //
  //     // Start cooldown timer
  //     _emailCooldown.value = 60;
  //     _startEmailCooldown();
  //
  //     _showOtpDialog('email');
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Error updating email: ${e.toString()}')),
  //     );
  //   }
  // }

  Future<void> _verifyPhone() async {
    if (_phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid phone number')),
      );
      return;
    }

    _newPhone = _phoneController.text;

    // await _auth.verifyPhoneNumber(
    //   phoneNumber: '+91${_phoneController.text}',
    //   verificationCompleted: (credential) async {
    //     await _auth.currentUser!.updatePhoneNumber(credential);
    //     setState(() {
    //       _isPhoneVerified = true;
    //       _isPhoneAdded = true;
    //     });
    //   },
    //   verificationFailed: (e) {
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       SnackBar(content: Text('Verification failed: ${e.message}')),
    //     );
    //   },
    //   codeSent: (verificationId, _) {
    //     setState(() => _verificationId = verificationId);
    //     // Start cooldown timer
    //     _phoneCooldown.value = 60;
    //     _startPhoneCooldown();
    //     _showOtpDialog('phone');
    //   },
    //   codeAutoRetrievalTimeout: (verificationId) {},
    // );
  }

  void _resendOtp(String type) async {
    if ((type == 'phone' && _phoneCooldown.value > 0) ||
        (type == 'email' && _emailCooldown.value > 0)) {
      return;
    }

    if (type == 'phone') {
      _phoneCooldown.value = 60;
      _startPhoneCooldown();
      await _verifyPhone();
    } else if (type == 'email') {
      _emailCooldown.value = 60;
      _startEmailCooldown();
      // await _verifyEmail();
    }
  }

  void _startPhoneCooldown() {
    _phoneCooldownTimer?.cancel();
    _phoneCooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_phoneCooldown.value > 0) {
        _phoneCooldown.value--;
      } else {
        timer.cancel();
      }
    });
  }

  void _startEmailCooldown() {
    _emailCooldownTimer?.cancel();
    _emailCooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_emailCooldown.value > 0) {
        _emailCooldown.value--;
      } else {
        timer.cancel();
      }
    });
  }

  void _showOtpDialog(String type) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Enter OTP sent to ${type == 'phone' ? 'your mobile' : 'your email'}',
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(labelText: '6-digit OTP'),
                ),
                const SizedBox(height: 10),
                ValueListenableBuilder<int>(
                  valueListenable:
                      type == 'phone' ? _phoneCooldown : _emailCooldown,
                  builder: (context, value, child) {
                    return Text(
                      value > 0 ? 'Resend available in ${value}s' : ' ',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    );
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  if (type == 'phone') {
                    _phoneController.text = _originalPhone;
                    setState(() {
                      _isPhoneChanged = false;
                      _updateHasUnsavedChanges();
                    });
                  } else if (type == 'email') {
                    _emailController.text = _originalEmail;
                    setState(() {
                      _isEmailChanged = false;
                      _updateHasUnsavedChanges();
                    });
                  }
                },
                child: const Text('Cancel'),
              ),
              ValueListenableBuilder<int>(
                valueListenable:
                    type == 'phone' ? _phoneCooldown : _emailCooldown,
                builder: (context, value, child) {
                  return TextButton(
                    onPressed: value > 0 ? null : () => _resendOtp(type),
                    child: Text(
                      'Resend OTP',
                      style: TextStyle(
                        color: value > 0 ? Colors.grey : Colors.red,
                      ),
                    ),
                  );
                },
              ),
              TextButton(
                onPressed: () async {
                  if (type == 'phone')
                  {
                 /*   try {
                      PhoneAuthCredential credential =
                          PhoneAuthProvider.credential(
                            verificationId: _verificationId!,
                            smsCode: controller.text,
                          );
                      await _auth.currentUser!.updatePhoneNumber(credential);
                      setState(() {
                        _isPhoneVerified = true;
                        _isPhoneAdded = true;
                        _newPhone = _phoneController.text;
                      });
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Phone number verified successfully'),
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Invalid OTP: $e')),
                      );
                    }*/
                  } else if (type == 'email') {
                    setState(() {
                      _isEmailVerified = true;
                    });
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Email verification confirmed'),
                      ),
                    );
                  }
                },
                child: const Text(
                  'Verify',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }

  Future<bool> _onWillPop() async {
    if (!_hasUnsavedChanges) return true;

    // Show confirmation dialog if there are unsaved changes
    final shouldPop = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Discard Changes?'),
            content: const Text(
              'You have unsaved changes. Are you sure you want to go back without saving?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Discard'),
              ),
            ],
          ),
    );

    return shouldPop ?? false;
  }

/*
  Future<void> _updateProfile() async {
    // Check if email or phone was changed but not verified
    if (_isEmailChanged && !_isEmailVerified) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please verify your email before updating profile'),
        ),
      );
      return;
    }

    if (_isPhoneChanged && !_isPhoneVerified) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please verify your phone number before updating profile',
          ),
        ),
      );
      return;
    }

    final user = _auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('User not authenticated')));
      return;
    }

    try {
      final userData = {
        'name': _nameController.text,
        'email': user.email,
        'phone': _phoneController.text,
        'gender': _gender,
        'dob': _dob?.toIso8601String(),
        'profilePictureUrl': _isImageDeleted ? null : _profileImageUrl,
      };

      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(userData, SetOptions(merge: true));

      final prefs = await SharedPreferences.getInstance();
      if (_isImageDeleted) {
        await prefs.remove('profilePicture');
      } else if (_profileImageUrl != null && _profileImageUrl!.isNotEmpty) {
        await prefs.setString('profilePicture', _profileImageUrl!);
      }

      widget.onProfileUpdated(_isImageDeleted ? '' : _profileImageUrl ?? '');

      // Reset change tracking after successful update
      setState(() {
        _originalEmail = _emailController.text;
        _originalPhone = _phoneController.text;
        _isEmailChanged = false;
        _isPhoneChanged = false;
        _hasUnsavedChanges = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating profile: ${e.toString()}')),
      );
    }
  }
*/

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text(
            'Your Profile',
            style: TextStyle(color: Colors.black),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () async {
              if (await _onWillPop()) {
                Navigator.pop(context);
              }
            },
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildProfilePictureSection(),
              const SizedBox(height: 30),
              _buildTextField(
                _nameController,
                'Name',
                Icons.person,
                readOnly: true,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                _emailController,
                'Email',
                Icons.email,
                showChangeButton: true,
                isVerified: !_isEmailChanged || _isEmailVerified,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                _phoneController,
                'Mobile',
                Icons.phone,
                showChangeButton: true,
                isVerified: !_isPhoneChanged || _isPhoneVerified,
              ),
              const SizedBox(height: 16),
              _buildGenderDropdown(),
              const SizedBox(height: 16),
              _buildDateOfBirthField(),
              const SizedBox(height: 30),
              _buildUpdateButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfilePictureSection() {
    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.grey[500],
            foregroundColor: Colors.white,
            backgroundImage:
                (_profileImageUrl != null && _profileImageUrl!.isNotEmpty)
                    ? FileImage(File(_profileImageUrl!))
                    : null,
            child:
                (_profileImageUrl == null || _profileImageUrl!.isEmpty)
                    ? Text(
                      widget.initialName.isNotEmpty
                          ? widget.initialName[0].toUpperCase()
                          : 'U',
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                    : null,
          ),
          Positioned(
            bottom: -10,
            right: -10,
            child: IconButton(
              icon: const Icon(Icons.camera_alt, color: Colors.red),
              onPressed: _uploadProfileImage,
            ),
          ),
          if (_profileImageUrl != null && _profileImageUrl!.isNotEmpty)
            Positioned(
              top: -10,
              right: -10,
              child: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: _deleteProfileImage,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool readOnly = false,
    bool showChangeButton = false,
    bool isVerified = true,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Icon(icon, color: Colors.grey),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                border: InputBorder.none,
                labelText: label,
                labelStyle: TextStyle(
                  color: isVerified ? Colors.grey[600] : Colors.red,
                ),
                suffixIcon:
                    !isVerified
                        ? const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 20,
                        )
                        : null,
              ),
              readOnly: readOnly || (showChangeButton && !isVerified),
            ),
          ),
          if (showChangeButton)
            TextButton(
              onPressed: label == 'Mobile' ? _verifyPhone : null/*_verifyEmail*/,
              child: Text(
                label == 'Mobile' && !_isPhoneAdded ? 'ADD' : 'CHANGE',
                style: const TextStyle(color: Colors.red),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGenderDropdown() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Padding(
            padding: EdgeInsets.all(12.0),
            child: Icon(Icons.person_outline, color: Colors.grey),
          ),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _gender,
                hint: const Text(
                  'Gender',
                  style: TextStyle(color: Colors.grey),
                ),
                isExpanded: true,
                icon: const Icon(Icons.arrow_drop_down),
                onChanged: (String? newValue) {
                  setState(() {
                    _gender = newValue;
                    _hasUnsavedChanges = true;
                  });
                },
                items:
                    _genderOptions.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateOfBirthField() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Padding(
            padding: EdgeInsets.all(12.0),
            child: Icon(Icons.calendar_today, color: Colors.grey),
          ),
          Expanded(
            child: InkWell(
              onTap: _selectDate,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Text(
                  _dob != null
                      ? DateFormat('dd/MM/yyyy').format(_dob!)
                      : 'Date of Birth',
                  style: TextStyle(
                    color: _dob != null ? Colors.black : Colors.grey,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dob ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _dob) {
      setState(() {
        _dob = picked;
        _hasUnsavedChanges = true;
      });
    }
  }

  Widget _buildUpdateButton() {
    bool canUpdate = !_isEmailChanged || _isEmailVerified;
    canUpdate = canUpdate && (!_isPhoneChanged || _isPhoneVerified);

    return ElevatedButton(
      onPressed: canUpdate ?null/* _updateProfile*/: null,
      style: ElevatedButton.styleFrom(
        backgroundColor: canUpdate ? Colors.red : Colors.grey,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: const Text('Update Profile'),
    );
  }
}
