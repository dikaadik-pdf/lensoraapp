import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cashierapp_simulationukk2026/models/produk_model.dart';
import 'package:cashierapp_simulationukk2026/widgets/confirm_dialog.dart';
import 'package:cashierapp_simulationukk2026/widgets/notification.dart';

class UpdateStockDialog extends StatefulWidget {
  final ProdukModel product;

  const UpdateStockDialog({super.key, required this.product});

  @override
  State<UpdateStockDialog> createState() => _UpdateStockDialogState();
}

class _UpdateStockDialogState extends State<UpdateStockDialog> {
  late TextEditingController _amountController;
  String _selectedType = 'Increase';
  bool _loading = false;

  final List<String> _types = ['Increase', 'Decrease'];

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController();
  }

  @override
  void dispose() {
    _amountController.dispose();
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

  Widget _inputField(TextEditingController controller) {
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
        keyboardType: TextInputType.number,
        style: GoogleFonts.poppins(color: Colors.white),
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
          hintStyle: GoogleFonts.poppins(color: Colors.white38),
        ),
      ),
    );
  }

  void _showError(String msg) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF2C3E50),
        content: Text(
          msg,
          style: GoogleFonts.poppins(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: GoogleFonts.poppins(color: const Color(0xFFE4B169)),
            ),
          ),
        ],
      ),
    );
  }

  void _showConfirmation() {
    if (_amountController.text.isEmpty) {
      _showError('Please enter amount!');
      return;
    }

    final amount = int.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      _showError('Please enter valid amount!');
      return;
    }

    if (_selectedType == 'Decrease' && amount > widget.product.stok) {
      _showError('Amount exceeds current stock!');
      return;
    }

    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (_) => ConfirmationDialog(
        logoAssetPath: "assets/images/lensoralogo.png",
        message: "Are You Sure About\nUpdating This Stock?",
        onNoPressed: () => Navigator.pop(context),
        onYesPressed: () {
          Navigator.pop(context); // Close confirmation
          _updateStock(amount);
        },
      ),
    );
  }

  Future<void> _updateStock(int amount) async {
    try {
      setState(() => _loading = true);

      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser?.id;

      final change = _selectedType == 'Increase' ? amount : -amount;
      final newStock = widget.product.stok + change;

      // Update stock in produk table
      await supabase
          .from('produk')
          .update({'stok': newStock})
          .eq('produkid', widget.product.produkID);

      // Insert log in stok_log table
      await supabase.from('stok_log').insert({
        'id_produk': widget.product.produkID,
        'perubahan': change,
        'keterangan': _selectedType == 'Increase' ? 'Restock' : 'Manual Adjustment',
        'id_user': userId,
      });

      if (mounted) {
        setState(() => _loading = false);
        
        // Show success notification on top of update dialog
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (notifContext) => SuccessNotificationDialog(
            message: "Stock updated\nsuccessfully!",
            onOkPressed: () {
              Navigator.of(notifContext).pop(); // Close notification
              Navigator.of(context).pop(true); // Close update dialog
            },
          ),
        );
      }
    } catch (e) {
      setState(() => _loading = false);
      _showError("Failed to update stock: $e");
    }
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
                Text(
                  "Update Stock",
                  style: GoogleFonts.poppins(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 20),

                _label("Name Product"),
                const SizedBox(height: 5),
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    width: 300,
                    height: 50,
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3A4C5E).withOpacity(0.5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      widget.product.namaProduk,
                      style: GoogleFonts.poppins(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                _label("Type Update"),
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
                      child: DropdownButton<String>(
                        value: _selectedType,
                        dropdownColor: const Color(0xFF2E343B),
                        iconEnabledColor: Colors.white,
                        style: GoogleFonts.poppins(color: Colors.white),
                        items: _types
                            .map((e) => DropdownMenuItem(
                                  value: e,
                                  child: Text(e),
                                ))
                            .toList(),
                        onChanged: (v) => setState(() => _selectedType = v!),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                _label("Amount (Stock)"),
                const SizedBox(height: 5),
                Align(
                  alignment: Alignment.center,
                  child: _inputField(_amountController),
                ),

                const SizedBox(height: 15),

                // Current Stock Info
                Container(
                  width: 300,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF25292E),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Current Stock:',
                        style: GoogleFonts.poppins(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        '${widget.product.stok}',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // CANCEL BUTTON
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

                    // SAVE BUTTON
                    SizedBox(
                      width: 100,
                      height: 35,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _showConfirmation,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFA500),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _loading
                            ? const SizedBox(
                                height: 16,
                                width: 16,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                "Save",
                                style: GoogleFonts.poppins(color: Colors.white),
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}