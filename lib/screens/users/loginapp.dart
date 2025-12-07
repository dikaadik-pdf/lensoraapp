import 'package:flutter/material.dart';
import 'package:cashierapp_simulationukk2026/services/auth_services.dart';
import 'package:cashierapp_simulationukk2026/screens/users/splash.dart';
import 'package:cashierapp_simulationukk2026/screens/users/dashboard.dart';
import 'package:cashierapp_simulationukk2026/widgets/notification.dart';

// ================== ERROR NOTIFICATION DIALOG ==================

class ErrorNotificationDialog extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onOkPressed;

  const ErrorNotificationDialog({
    super.key,
    this.title = "Error",
    required this.message,
    this.onOkPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 300,
        height: 255,
        decoration: BoxDecoration(
          color: const Color(0xFF3A4C5E),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 300,
              height: 105,
              decoration: const BoxDecoration(
                color: Color(0xFF2E343B),
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Center(
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE6E4E1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Color(0xFFBF0505),
                    size: 40,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      message,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        height: 1.3,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Center(
                      child: SizedBox(
                        width: 100,
                        height: 35,
                        child: ElevatedButton(
                          onPressed: onOkPressed ?? () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2E343B),
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            "Ok",
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================== LOGIN PAGE ==================

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  bool _loading = false;
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Masukkan email';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Format email tidak valid';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Masukkan password';
    }
    return null;
  }

  Future<void> _submit() async {
    // Validasi manual
    final emailError = _validateEmail(_emailCtrl.text);
    final passError = _validatePassword(_passCtrl.text);

    if (emailError != null) {
      showDialog(
        context: context,
        builder: (_) => const ErrorNotificationDialog(
          title: "Email Tidak Valid",
          message: "Masukkan email dengan format yang benar\ncontoh: lensora@petugas.com",
        ),
      );
      return;
    }

    if (passError != null) {
      showDialog(
        context: context,
        builder: (_) => const ErrorNotificationDialog(
          title: "Password Kosong",
          message: "Masukkan password Anda",
        ),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final auth = AuthService();
      final res = await auth.login(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text,
      );

      if (res == null) {
        if (!mounted) return;
        showDialog(
          context: context,
          builder: (_) => const ErrorNotificationDialog(
            title: "Login Gagal",
            message: "Email atau password yang kamu\nmasukkan salah.",
          ),
        );
        return;
      }

      final role = res["role"] ?? "user";

      if (!mounted) return;

      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => SuccessNotificationDialog(
          message: "Selamat Datang Kembali! Selamat Bekerja!",
          onOkPressed: () {
            Navigator.pop(context);
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => DashboardScreen(role: role)),
            );
          },
        ),
      );
    } catch (e) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (_) => ErrorNotificationDialog(
          title: "Terjadi Kesalahan",
          message: e.toString().contains("network")
              ? "Tidak dapat terhubung ke server.\nPeriksa koneksi internet."
              : "Error: ${e.toString()}",
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFF25292E);
    const outerContainerColor = Color(0xFF2E343B);
    const inputColor = Color(0xFF1D1F21);
    const backBtnColor = Color(0xFF1D1F21);
    const loginBtnColor = Color(0xFF3A4C5E);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),
            Image.asset('assets/images/lensoralogo.png', width: 110, height: 65),
            const SizedBox(height: 20),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Center(
                  child: Container(
                    width: 385,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                    decoration: BoxDecoration(
                      color: outerContainerColor,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Center(
                          child: Text(
                            "Log In",
                            style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 35),

                        Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // ========== EMAIL FIELD ==========
                              const Text(
                                "E-mail",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                width: 340,
                                height: 55,
                                decoration: BoxDecoration(
                                  color: inputColor,
                                  borderRadius: BorderRadius.circular(25),
                                  border: _validateEmail(_emailCtrl.text) != null && _emailCtrl.text.isNotEmpty
                                      ? Border.all(color: Colors.redAccent, width: 1.5)
                                      : null,
                                ),
                                child: Center(
                                  child: TextField(
                                    controller: _emailCtrl,
                                    onChanged: (value) => setState(() {}),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontFamily: "Poppins",
                                    ),
                                    decoration: const InputDecoration(
                                      hintText: 'lensoracompany@domain.com',
                                      hintStyle: TextStyle(color: Colors.white38),
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                                    ),
                                    keyboardType: TextInputType.emailAddress,
                                  ),
                                ),
                              ),
                              
                              // ✅ ERROR MESSAGE DI BAWAH
                              if (_emailCtrl.text.isNotEmpty && _validateEmail(_emailCtrl.text) != null)
                                Padding(
                                  padding: const EdgeInsets.only(left: 20, top: 6),
                                  child: Text(
                                    _validateEmail(_emailCtrl.text)!,
                                    style: const TextStyle(
                                      color:  const Color(0xFFD32F2F),
                                      fontSize: 14,
                                    ),
                                  ),
                                ),

                              const SizedBox(height: 16),

                              // ========== PASSWORD FIELD ==========
                              const Text(
                                "Password",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                width: 340,
                                height: 55,
                                decoration: BoxDecoration(
                                  color: inputColor,
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller: _passCtrl,
                                        obscureText: !_isPasswordVisible,
                                        onChanged: (value) => setState(() {}),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                          fontFamily: "Poppins",
                                        ),
                                        decoration: const InputDecoration(
                                          hintText: 'Input Password',
                                          hintStyle: TextStyle(color: Colors.white38),
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.symmetric(vertical: 14),
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                                      icon: Icon(
                                        _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 130),

                        // ========== BUTTONS ==========
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 145,
                              height: 45,
                              child: ElevatedButton(
                                onPressed: () => Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (_) => const SplashScreen()),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: backBtnColor,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(17)),
                                ),
                                child: const Text(
                                  "Back",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 18),
                            SizedBox(
                              width: 145,
                              height: 45,
                              child: ElevatedButton(
                                onPressed: _loading ? null : _submit,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: loginBtnColor,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(17)),
                                ),
                                child: _loading
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Text(
                                        "Log In",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}