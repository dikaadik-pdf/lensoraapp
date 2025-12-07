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
        width: 300,
        height: 210,
        decoration: BoxDecoration(
          color: const Color(0xFF3A4C5E),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // LOGO dari assets lokal
              Image.asset(
                logoAssetPath,
                height: 45,
                fit: BoxFit.contain,
              ),

              const SizedBox(height: 16),

              // MESSAGE
              Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 20),

              // BUTTON NO & YES
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // NO BUTTON — Merah
                  SizedBox(
                    width: 100,
                    height: 35,
                    child: ElevatedButton(
                      onPressed: onNoPressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFBF0505),
                        padding: EdgeInsets.zero,
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

                  const SizedBox(width: 16),

                  // YES BUTTON — Abu Gelap
                  SizedBox(
                    width: 100,
                    height: 35,
                    child: ElevatedButton(
                      onPressed: onYesPressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E343B),
                        padding: EdgeInsets.zero,
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