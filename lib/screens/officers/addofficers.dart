// lib/screens/officers/addofficers_with_auth.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cashierapp_simulationukk2026/services/officers_services.dart';
import 'package:cashierapp_simulationukk2026/widgets/notification.dart';
import 'package:cashierapp_simulationukk2026/widgets/confirm_dialog.dart';

class AddOfficerDialogWithAuth extends StatefulWidget {
  const AddOfficerDialogWithAuth({super.key});

  @override
  State<AddOfficerDialogWithAuth> createState() =>
      _AddOfficerDialogWithAuthState();
}

class _AddOfficerDialogWithAuthState extends State<AddOfficerDialogWithAuth> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final OfficerService _officerService = OfficerService();

  bool _loading = false;
  bool _obscurePassword = true;
  String _selectedCategory = 'Officers';
  final List<String> _categories = ['Officers', 'Admin'];

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Widget _label(String text) {
    return Align(
      alignment: Alignment.center,
      child: Container(
        width: 300,
        padding: const EdgeInsets.only(left: 5),
        child: Text(
          text,
          style: GoogleFonts.poppins(
            color: Colors.white70,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _inputField(
    TextEditingController controller, {
    bool isPassword = false,
    String? hintText,
  }) {
    return Container(
      width: 300,
      height: 50,
      decoration: BoxDecoration(
        color: const Color(0xFF3A4C5E),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: isPassword ? TextInputType.text : TextInputType.emailAddress,
        obscureText: isPassword ? _obscurePassword : false,
        style: GoogleFonts.poppins(color: Colors.white),
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
          hintText: hintText,
          hintStyle: GoogleFonts.poppins(color: Colors.white38),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: Colors.white38,
                  ),
                  onPressed: () {
                    setState(() => _obscurePassword = !_obscurePassword);
                  },
                )
              : null,
        ),
      ),
    );
  }

  void _confirmSaveOfficer() {
    if (_emailController.text.trim().isEmpty || _passwordController.text.isEmpty) {
      _showError('Please fill all fields!');
      return;
    }

    final email = _emailController.text.trim();

    // Validasi email format
    final emailRegex = RegExp(r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      _showError('Please enter a valid email address!\n(e.g., user@example.com)');
      return;
    }

    // Validasi password minimal 6 karakter
    if (_passwordController.text.length < 6) {
      _showError('Password must be at least 6 characters!');
      return;
    }

    // Validasi password tidak boleh terlalu simple
    final commonPasswords = ['123456', 'password', '12345678', 'qwerty', 'abc123'];
    if (commonPasswords.contains(_passwordController.text.toLowerCase())) {
      _showError('Password too common! Please use a stronger password.');
      return;
    }

    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (_) => ConfirmationDialog(
        logoAssetPath: "assets/images/lensoralogo.png",
        message: "Are You Sure About Adding This Officer?",
        onNoPressed: () => Navigator.pop(context),
        onYesPressed: () {
          Navigator.pop(context);
          _saveOfficer();
        },
      ),
    );
  }

  Future<void> _saveOfficer() async {
    if (!mounted) return;

    try {
      setState(() => _loading = true);

      final email = _emailController.text.trim();
      final fullName = email.split('@')[0];

      print('🚀 Creating officer: $email');

      // Call service
      final officer = await _officerService.addOfficerWithAuth(
        fullName: fullName,
        email: email,
        password: _passwordController.text,
        category: _selectedCategory,
      );

      print('✅ Officer created: ${officer.id}');

      if (!mounted) return;

      setState(() => _loading = false);
      
      // Close dialog dengan signal refresh
      Navigator.pop(context, true);

      // Show success notification
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => SuccessNotificationDialog(
          message:
              "✅ Officer added successfully!Selamat Bergabung",
          onOkPressed: () {
            Navigator.pop(context);
          },
        ),
      );
    } catch (e) {
      print('❌ Error: $e');
      
      if (!mounted) return;
      
      setState(() => _loading = false);

      // Parse error
      String errorMsg = e.toString()
          .replaceAll('Exception: ', '')
          .replaceAll('Failed to add officer: ', '')
          .trim();

      // Handle specific errors
      if (errorMsg.contains('SYNC_ERROR')) {
        _showError(
          '⚠️ Sync Delay Detected\n\n'
          'The account was created but there was a delay syncing to the database.\n\n'
          '✅ Please CLOSE this dialog and REFRESH the page.\n\n'
          'If the user still doesn\'t appear:\n'
          '1. Check Supabase RLS policies\n'
          '2. Check database trigger\n'
          '3. Check console logs',
          title: 'Warning',
          isWarning: true,
          onClose: () {
            Navigator.pop(context, true); // Signal refresh
          },
        );
        return;
      }

      if (errorMsg.contains('Email sudah terdaftar') || 
          errorMsg.contains('already registered')) {
        errorMsg = '❌ Email Already Registered!\n\nPlease use a different email.';
      } else if (errorMsg.contains('Format email tidak valid') || 
                 errorMsg.contains('Invalid email')) {
        errorMsg = '❌ Invalid Email Format!\n\nExample: user@example.com';
      } else if (errorMsg.contains('Password terlalu lemah') || 
                 errorMsg.contains('Password should be at least')) {
        errorMsg = '❌ Password Too Weak!\n\nMinimum 6 characters required.';
      } else if (errorMsg.contains('Email confirmation enabled')) {
        errorMsg = 
            '⚠️ Email Confirmation is Enabled\n\n'
            'Please disable it in Supabase:\n\n'
            '1. Go to Authentication > Providers\n'
            '2. Click on Email\n'
            '3. Uncheck "Confirm email"\n'
            '4. Save changes';
      } else if (errorMsg.contains('User registration disabled')) {
        errorMsg = 
            '⚠️ User Registration is Disabled\n\n'
            'Please enable it in Supabase:\n\n'
            '1. Go to Authentication > Providers\n'
            '2. Click on Email\n'
            '3. Check "Enable Email provider"\n'
            '4. Save changes';
      } else if (errorMsg.contains('Permission denied') || 
                 errorMsg.contains('RLS')) {
        errorMsg = 
            '⚠️ Permission Denied\n\n'
            'Your RLS policies might be blocking this action.\n\n'
            'Please check:\n'
            '1. SELECT policy allows reading all users\n'
            '2. INSERT policy allows admin to create users\n'
            '3. Run the SQL script provided in setup guide';
      } else if (errorMsg.contains('No data found')) {
        errorMsg = 
            '⚠️ Data Not Found\n\n'
            'The user was created but cannot be read back.\n\n'
            'This is usually a RLS SELECT policy issue.\n'
            'Check your Supabase RLS settings.';
      } else if (errorMsg.contains('Network')) {
        errorMsg = '❌ Network Error!\n\nPlease check your internet connection.';
      }

      _showError(errorMsg);
    }
  }

  void _showError(
    String msg, {
    String title = 'Error',
    bool isWarning = false,
    VoidCallback? onClose,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF2C3E50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: Row(
          children: [
            Icon(
              isWarning ? Icons.warning_amber_rounded : Icons.error_outline,
              color: isWarning ? Colors.orange : Colors.red,
              size: 28,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  color: isWarning ? Colors.orange : Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Text(
            msg,
            style: GoogleFonts.poppins(
              color: Colors.white70,
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onClose?.call();
            },
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              backgroundColor: isWarning 
                  ? Colors.orange.withOpacity(0.1) 
                  : Colors.red.withOpacity(0.1),
            ),
            child: Text(
              'OK',
              style: GoogleFonts.poppins(
                color: isWarning ? Colors.orange : Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
      child: Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        backgroundColor: Colors.transparent,
        child: Container(
          width: 345,
          decoration: BoxDecoration(
            color: const Color(0xFF2E343B),
            borderRadius: BorderRadius.circular(18),
          ),
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Text(
                  "Add New Officers",
                  style: GoogleFonts.poppins(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Create login account for new officer",
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.white54,
                  ),
                ),
                const SizedBox(height: 25),

                // Email
                _label("Email"),
                const SizedBox(height: 5),
                Align(
                  alignment: Alignment.center,
                  child: _inputField(
                    _emailController,
                    hintText: 'example@email.com',
                  ),
                ),
                const SizedBox(height: 15),

                // Password
                _label("Password"),
                const SizedBox(height: 5),
                Align(
                  alignment: Alignment.center, 
                  child: _inputField(
                    _passwordController,
                    isPassword: true,
                    hintText: 'Min. 6 characters',
                  ),
                ),
                const SizedBox(height: 15),

                // Category
                _label("Category"),
                const SizedBox(height: 5),
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    width: 300,
                    height: 50,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3A4C5E),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton(
                        value: _selectedCategory,
                        dropdownColor: const Color(0xFF2E343B),
                        iconEnabledColor: Colors.white,
                        style: GoogleFonts.poppins(color: Colors.white),
                        items: _categories
                            .map((e) =>
                                DropdownMenuItem(value: e, child: Text(e)))
                            .toList(),
                        onChanged: (v) =>
                            setState(() => _selectedCategory = v!),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Text(
                    "This officer will be able to login using the email and password above",
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: Colors.orange.shade300,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 30),

                // Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 100,
                      height: 35,
                      child: ElevatedButton(
                        onPressed: _loading
                            ? null
                            : () => Navigator.pop(context, false),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade700,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          "Cancel",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    SizedBox(
                      width: 100,
                      height: 35,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _confirmSaveOfficer,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFA500),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _loading
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    "Wait",
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              )
                            : Text(
                                "Create",
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}