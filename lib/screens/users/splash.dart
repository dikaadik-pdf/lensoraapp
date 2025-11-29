import 'package:flutter/material.dart';
import 'package:cashierapp_simulationukk2026/screens/users/loginapp.dart';
import 'package:cashierapp_simulationukk2026/screens/users/signupapp.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  static const Color bgColor = Color(0xFF25292E);
  static const Color containerColor = Color(0xFF2E343B);

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          /// LOGO DI TENGAH TENGAH (PRESISI)
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: EdgeInsets.only(bottom: 50), // LOGO NAIK
              child: Image.asset(
                'assets/images/lensoralogo.png',
                width: 230,
                fit: BoxFit.contain,
              ),
            ),
          ),

          /// CONTAINER BAWAH
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: media.width,
              height: media.height * 0.35,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
              decoration: const BoxDecoration(
                color: containerColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(140),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// TEXT WELCOME (LEBIH KE DALAM, BUKAN MEPET KIRI)
                  const Text(
                    'Welcome!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Poppins',
                    ),
                  ),

                  const SizedBox(height: 24),

                  /// BUTTON REGISTER
                  SizedBox(
                    width: 280,
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF56768A),
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const RegisterPage(),
                          ),
                        );
                      },
                      child: const Text(
                        'Register',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  /// Teks "Or"
                  Padding(
                    padding: const EdgeInsets.only(left: 130),
                    child: Text(
                      "Or",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  /// BUTTON LOGIN
                  SizedBox(
                    width: 280,
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E1F20),
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginPage()),
                        );
                      },
                      child: const Text(
                        'Log In',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins',
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
    );
  }
}
