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
    // Validasi input
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showError('Please fill all fields!');
      return;
    }

    // Validasi email format
    if (!_emailController.text.contains('@')) {
      _showError('Please enter a valid email address!');
      return;
    }

    // Validasi password minimal 6 karakter
    if (_passwordController.text.length < 6) {
      _showError('Password must be at least 6 characters!');
      return;
    }

    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (_) => ConfirmationDialog(
        logoAssetPath: "assets/images/lensoralogo.png",
        message:
            "Are You Sure About Adding This Officer?",
        onNoPressed: () => Navigator.pop(context),
        onYesPressed: () {
          Navigator.pop(context); // Close confirmation
          _saveOfficer();
        },
      ),
    );
  }

  Future<void> _saveOfficer() async {
    try {
      setState(() => _loading = true);

      // Gunakan email sebagai full_name juga (atau bisa custom)
      final email = _emailController.text.trim();
      final fullName = email.split('@')[0]; // Ambil username dari email

      // Gunakan service untuk add officer dengan auth
      await _officerService.addOfficerWithAuth(
        fullName: fullName, // Auto-generate dari email
        email: email,
        password: _passwordController.text,
        category: _selectedCategory,
      );

      if (mounted) {
        setState(() => _loading = false);
        Navigator.pop(context, true); // Close add dialog dengan signal refresh

        // Show success notification
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => SuccessNotificationDialog(
            message:
                "Officer added successfully!\n\nLogin credentials created for:\n$email",
            onOkPressed: () {
              Navigator.pop(context); // Close notification
            },
          ),
        );
      }
    } catch (e) {
      setState(() => _loading = false);

      // Handle specific error messages
      String errorMsg = e.toString();
      if (errorMsg.contains('already registered')) {
        errorMsg = 'Email already registered!';
      } else if (errorMsg.contains('Invalid email')) {
        errorMsg = 'Invalid email format!';
      } else if (errorMsg.contains('Password')) {
        errorMsg = 'Password too weak!';
      }

      _showError('Failed: $errorMsg');
    }
  }

  void _showError(String msg) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF2C3E50),
        title: Text(
          'Error',
          style: GoogleFonts.poppins(
            color: Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          msg,
          style: GoogleFonts.poppins(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: GoogleFonts.poppins(color: Colors.orange),
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
                // Title
                Text(
                  "Add New Officers",
                  style: GoogleFonts.poppins(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 10),

                // Subtitle
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

                // Info text
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Text(
                    "💡 This officer will be able to login using the email and password above",
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
                          style: GoogleFonts.poppins(color: Colors.white),
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
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                "Create",
                                style: GoogleFonts.poppins(color: Colors.white),
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