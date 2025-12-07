import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cashierapp_simulationukk2026/models/pelanggan_models.dart';
import 'package:cashierapp_simulationukk2026/services/helpercustomer.dart';
import 'package:cashierapp_simulationukk2026/widgets/notification.dart';
import 'package:cashierapp_simulationukk2026/widgets/confirm_dialog.dart';

class EditCustomerDialog extends StatefulWidget {
  final PelangganModel customer;

  const EditCustomerDialog({Key? key, required this.customer})
      : super(key: key);

  @override
  State<EditCustomerDialog> createState() => _EditCustomerDialogState();
}

class _EditCustomerDialogState extends State<EditCustomerDialog> {
  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _phoneController;

  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.customer.namaPelanggan,
    );
    _addressController = TextEditingController(
      text: widget.customer.alamat ?? "",
    );
    _phoneController = TextEditingController(
      text: widget.customer.nomorTelepon ?? "",
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Widget _label(String text) {
    return Container(
      width: 300,
      padding: const EdgeInsets.only(left: 5),
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _inputField(TextEditingController controller, {bool number = false}) {
    return Container(
      width: 300,
      height: 50,
      decoration: BoxDecoration(
        color: const Color(0xFF3A4C5E),
        borderRadius: BorderRadius.circular(25),
      ),
      child: TextField(
        controller: controller,
        keyboardType: number ? TextInputType.phone : TextInputType.text,
        style: const TextStyle(color: Colors.white),
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 14),
          hintStyle: TextStyle(color: Colors.white38),
        ),
      ),
    );
  }

  void _confirmUpdateCustomer() {
    if (_nameController.text.trim().isEmpty) {
      _showError("Name can't be empty!");
      return;
    }

  
    showDialog(
      context: context,
      builder: (_) => ConfirmationDialog(
        logoAssetPath: "assets/images/lensoralogo.png",
        message: "Are You Sure About Updating This Customer?",
        onNoPressed: () => Navigator.pop(context),
        onYesPressed: () {
          Navigator.pop(context); 
          _updateCustomer();
        },
      ),
    );
  }

  Future<void> _updateCustomer() async {
    setState(() => _loading = true);

    try {
      final updatedCustomer = PelangganModel(
        pelangganID: widget.customer.pelangganID,
        namaPelanggan: _nameController.text.trim(),
        alamat: _addressController.text.trim().isEmpty
            ? null
            : _addressController.text.trim(),
        nomorTelepon: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        lastTransaction: widget.customer.lastTransaction,
        totalExpenditure: widget.customer.totalExpenditure,
      );

      // Simpan ke database
      final result = await PelangganDatabaseHelper.updatePelanggan(
        updatedCustomer,
      );

      if (!mounted) return;

      if (result != null) {
        setState(() => _loading = false);
        Navigator.of(context).pop(); 
        
        
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => SuccessNotificationDialog(
            message: "Customer updated\nsuccessfully!",
            onOkPressed: () {
              Navigator.pop(context); 
              Navigator.pop(context, true); 
            },
          ),
        );
      } else {
        setState(() => _loading = false);
        _showError("Failed to update customer");
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      _showError("Failed to update: $e");
    }
  }

  void _showError(String msg) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF2E343B),
        title: const Text('Error', style: TextStyle(color: Colors.white)),
        content: Text(msg, style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              'OK',
              style: TextStyle(color: Color(0xFFE4B169)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: GestureDetector(
        onTap: () {}, 
        child: Container(
          color: Colors.black.withOpacity(0.5),
          child: Center(
            child: GestureDetector(
              onTap: () {}, 
              child: Container(
                width: 345,
                height: 655,
                decoration: BoxDecoration(
                  color: const Color(0xFF2E343B),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 30),
                    child: Column(
                      children: [
                        const Text(
                          "Edit Customer",
                          style: TextStyle(
                            fontSize: 25,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 35),

                        _label("Full Name"),
                        const SizedBox(height: 5),
                        _inputField(_nameController),

                        const SizedBox(height: 20),
                        _label("Address"),
                        const SizedBox(height: 5),
                        _inputField(_addressController),

                        const SizedBox(height: 20),
                        _label("Phone Number"),
                        const SizedBox(height: 5),
                        _inputField(_phoneController, number: true),

                        const SizedBox(height: 145),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: _loading
                                    ? null
                                    : () {
                                        Navigator.of(context).pop(false);
                                      },
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  width: 100,
                                  height: 35,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFBF0505),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  alignment: Alignment.center,
                                  child: const Text(
                                    "Cancel",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 40),
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: _loading ? null : _confirmUpdateCustomer,
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  width: 100,
                                  height: 35,
                                  decoration: BoxDecoration(
                                    color: _loading
                                        ? const Color(0xFFE4B169)
                                            .withOpacity(0.6)
                                        : const Color(0xFFE4B169),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  alignment: Alignment.center,
                                  child: _loading
                                      ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Text(
                                          "Save",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}