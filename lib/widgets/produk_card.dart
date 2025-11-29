import 'package:flutter/material.dart';

class ProdukCard extends StatelessWidget {
  final String nama;
  final double harga;
  final String? fotoUrl;
  final VoidCallback onTap;

  const ProdukCard({
    super.key,
    required this.nama,
    required this.harga,
    required this.onTap,
    this.fotoUrl,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              blurRadius: 4,
              spreadRadius: 1,
              color: Colors.black.withOpacity(0.05),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            fotoUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(fotoUrl!, height: 100, fit: BoxFit.cover),
                  )
                : Container(
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
            const SizedBox(height: 12),
            Text(nama, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
            const SizedBox(height: 4),
            Text("Rp ${harga.toStringAsFixed(0)}",
                style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
