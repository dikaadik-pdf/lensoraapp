import 'package:flutter/material.dart';
import 'package:cashierapp_simulationukk2026/services/auth_services.dart';
import 'package:cashierapp_simulationukk2026/screens/signupapp.dart';
import 'package:cashierapp_simulationukk2026/screens/dashboard.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  static const Color bgColor = Color(0xFF25292E);
  static const Color containerColor = Color(0xFF2E343B);
  static const Color inputColor = Color(0xFF1E1F20);

  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  bool _isPasswordVisible = false;
  bool _loading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      final auth = AuthService();
      final res = await auth.login(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text,
      );

      if (res != null) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const DashboardScreen()));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Login gagal')));
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
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 35),
                    decoration: BoxDecoration(
                        color: containerColor, borderRadius: BorderRadius.circular(25)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Center(
                            child: Text('Login',
                                style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w900,
                                    fontFamily: 'Poppins',
                                    color: Colors.white))),
                        const SizedBox(height: 30),
                        Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('E-mail',
                                  style: TextStyle(color: Colors.white, fontSize: 14)),
                              const SizedBox(height: 8),
                              _buildInputField(
                                  controller: _emailCtrl,
                                  hint: 'Input Email',
                                  validator: (v) =>
                                      (v == null || v.isEmpty) ? 'Masukkan email' : null),
                              const SizedBox(height: 18),
                              const Text('Password',
                                  style: TextStyle(color: Colors.white, fontSize: 14)),
                              const SizedBox(height: 8),
                              _buildInputField(
                                  controller: _passCtrl,
                                  hint: 'Input Password',
                                  obscure: !_isPasswordVisible,
                                  validator: (v) =>
                                      (v == null || v.isEmpty) ? 'Masukkan password' : null,
                                  suffix: _visibilityToggle()),
                            ],
                          ),
                        ),
                        const SizedBox(height: 35),
                        Row(
                          children: [
                            _buildButton(
                                label: "Register",
                                bgColor: Colors.black,
                                onTap: () {
                                  Navigator.pushReplacement(context,
                                      MaterialPageRoute(builder: (_) => const RegisterPage()));
                                }),
                            const SizedBox(width: 16),
                            _buildButton(
                                label: "Login",
                                bgColor: const Color(0xFF56768A),
                                onTap: _loading ? null : _submit,
                                loading: _loading)
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
          bool loading = false}) =>
      Expanded(
        child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: bgColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(17))),
          child: loading
              ? const SizedBox(
                  width: 23,
                  height: 35,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : Text(label,
                  style: const TextStyle(
                      color: Colors.white, fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 20)),
        ),
      );

  Widget _buildInputField(
          {required TextEditingController controller,
          required String hint,
          required String? Function(String?) validator,
          bool obscure = false,
          Widget? suffix}) =>
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(color: inputColor, borderRadius: BorderRadius.circular(25)),
        child: TextFormField(
          controller: controller,
          obscureText: obscure,
          style: const TextStyle(color: Colors.white, fontFamily: 'Poppins', fontSize: 14),
          decoration: InputDecoration(
              border: InputBorder.none,
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
              suffixIcon: suffix,
              contentPadding: const EdgeInsets.symmetric(vertical: 16)),
          validator: validator,
        ),
      );

  Widget _visibilityToggle() => IconButton(
        icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off, color: Colors.white70),
        onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
      );
}