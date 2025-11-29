import 'package:flutter/material.dart';
import 'package:cashierapp_simulationukk2026/services/auth_services.dart';
import 'package:cashierapp_simulationukk2026/screens/users/dashboard.dart';
import 'package:cashierapp_simulationukk2026/screens/users/splash.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  static const Color bgColor = Color(0xFF25292E);
  static const Color containerColor = Color(0xFF2E343B);
  static const Color inputColor = Color(0xFF1E1F20);

  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _isPasswordVisible = false;
  bool _loading = false;
  String _role = 'Admin';

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_passCtrl.text != _confirmCtrl.text) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Password tidak sama')));
      return;
    }

    setState(() => _loading = true);

    try {
      final auth = AuthService();
      final res = await auth.signUp(
        email: _emailCtrl.text,
        password: _passCtrl.text,
        role: _role.toLowerCase(),
      );

      if (res == 'Sign up berhasil') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => DashboardScreen(role: _role)),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Register berhasil')),
        );
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(res)));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 30, bottom: 10),
              child: Image.asset(
                'assets/images/lensoralogo.png',
                width: 110,
                height: 65,
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Center(
                  child: Container(
                    width: media.width * 0.92,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 35),
                    decoration: BoxDecoration(
                      color: containerColor,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Center(
                          child: Text(
                            'Sign Up',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              fontFamily: 'Poppins',
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Register As',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 14)),
                              const SizedBox(height: 8),
                              _buildInputDropdown(),
                              const SizedBox(height: 18),
                              const Text('E-mail',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 14)),
                              const SizedBox(height: 8),
                              _buildInputField(
                                  controller: _emailCtrl,
                                  hint: 'Input Email',
                                  validator: (v) => (v == null || v.isEmpty)
                                      ? 'Masukkan email'
                                      : null),
                              const SizedBox(height: 18),
                              const Text('Password',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 14)),
                              const SizedBox(height: 8),
                              _buildInputField(
                                  controller: _passCtrl,
                                  hint: 'Input Password',
                                  obscure: !_isPasswordVisible,
                                  validator: (v) => (v == null || v.length < 6)
                                      ? 'Minimal 6 karakter'
                                      : null,
                                  suffix: _visibilityToggle()),
                              const SizedBox(height: 18),
                              const Text('Confirm Password',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 14)),
                              const SizedBox(height: 8),
                              _buildInputField(
                                  controller: _confirmCtrl,
                                  hint: 'Re-confirm Password',
                                  obscure: !_isPasswordVisible,
                                  validator: (v) => (v == null || v.isEmpty)
                                      ? 'Konfirmasi password'
                                      : null,
                                  suffix: _visibilityToggle()),
                            ],
                          ),
                        ),
                        const SizedBox(height: 35),
                        Row(
                          children: [
                            _buildButton(
                              label: "Back",
                              bgColor: Colors.black,
                              onTap: () {
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) =>
                                            const SplashScreen()));
                              },
                            ),
                            const SizedBox(width: 16),
                            _buildButton(
                              label: "Register",
                              bgColor: const Color(0xFF56768A),
                              onTap: _loading ? null : _submit,
                              loading: _loading,
                            )
                          ],
                        ),
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

  Widget _buildButton(
      {required String label,
      required Color bgColor,
      required VoidCallback? onTap,
      bool loading = false}) {
    return Expanded(
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: bgColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(17)),
        ),
        child: loading
            ? const SizedBox(
                width: 23,
                height: 35,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2))
            : Text(label,
                style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    fontSize: 20)),
      ),
    );
  }

  Widget _buildInputField(
      {required TextEditingController controller,
      required String hint,
      required String? Function(String?) validator,
      bool obscure = false,
      Widget? suffix}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
          color: inputColor, borderRadius: BorderRadius.circular(25)),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        style: const TextStyle(
            color: Colors.white, fontFamily: 'Poppins', fontSize: 14),
        decoration: InputDecoration(
            border: InputBorder.none,
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
            suffixIcon: suffix,
            contentPadding: const EdgeInsets.symmetric(vertical: 16)),
        validator: validator,
      ),
    );
  }

  Widget _buildInputDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
          color: inputColor, borderRadius: BorderRadius.circular(25)),
      child: DropdownButtonFormField<String>(
        value: _role,
        dropdownColor: inputColor,
        style: const TextStyle(
            color: Colors.white, fontFamily: 'Poppins', fontSize: 16),
        decoration: const InputDecoration(
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 16)),
        icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
        items: const [
          DropdownMenuItem(
              value: 'Admin',
              child: Text('Admin', style: TextStyle(color: Colors.white))),
          DropdownMenuItem(
              value: 'Petugas',
              child: Text('Officer', style: TextStyle(color: Colors.white))),
        ],
        onChanged: (v) => setState(() => _role = v ?? 'Admin'),
      ),
    );
  }

  Widget _visibilityToggle() {
    return IconButton(
      icon: Icon(_isPasswordVisible
          ? Icons.visibility
          : Icons.visibility_off, color: Colors.white70),
      onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
    );
  }
}
