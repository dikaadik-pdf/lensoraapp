import 'package:flutter/material.dart';

class ConfirmationDialog extends StatelessWidget {
  final String logoAssetPath;
  final String message;
  final VoidCallback onNoPressed;
  final VoidCallback onYesPressed;

  const ConfirmationDialog({
    super.key,
    required this.logoAssetPath,
    required this.message,
    required this.onNoPressed,
    required this.onYesPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 330,
        decoration: BoxDecoration(
          color: const Color(0xFF3A4C5E),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 26),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // LOGO
              Image.asset(
                logoAssetPath,
                height: 50,
                fit: BoxFit.contain,
              ),

              const SizedBox(height: 22),

              // MESSAGE (Tengah, Bold)
              Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 26),

              // BUTTON NO & YES
              Row(
                children: [
                  // NO BUTTON — Merah
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onNoPressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFBF0505),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "No",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 14),

                  // YES BUTTON — Abu Gelap
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onYesPressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E343B),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Yes",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
