import 'package:flutter/material.dart';

// ===========================================================
//  SUCCESS NOTIFICATION DIALOG
// ===========================================================

class SuccessNotificationDialog extends StatelessWidget {
  final String message;
  final VoidCallback? onOkPressed;

  const SuccessNotificationDialog({
    super.key,
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
          children: [
            // Bagian Atas - Container dengan Icon
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
                    Icons.check,
                    color: Color(0xFF2E343B),
                    size: 40,
                  ),
                ),
              ),
            ),

            // Bagian Teks & Button
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // MESSAGE
                    if (message.isNotEmpty)
                      Text(
                        message,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),

                    // Tombol OK
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