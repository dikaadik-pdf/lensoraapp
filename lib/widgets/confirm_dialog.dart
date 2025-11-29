// ===========================================================
//  CONFIRMATION DIALOG
// ===========================================================
import 'package:flutter/material.dart';


class ConfirmationDialog extends StatelessWidget {
  final String logoAssetPath;
  final String title;
  final String message;
  final VoidCallback onNoPressed;
  final VoidCallback onYesPressed;

  const ConfirmationDialog({
    super.key,
    required this.logoAssetPath,
    required this.title,
    required this.message,
    required this.onNoPressed,
    required this.onYesPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 320,
        decoration: BoxDecoration(
          color: const Color(0xFF34495E),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Logo
              Image.asset(
                logoAssetPath,
                height: 60,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 20),

              // Title
              Text(
                title,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 10),

              // Message
              Text(
                message,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 20),

              // Button Row (NO & YES)
              Row(
                children: [
                  // NO BUTTON (Merah)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onNoPressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text("No",
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // YES BUTTON (Biru)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onYesPressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3498DB),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text("Yes",
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
