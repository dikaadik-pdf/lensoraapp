import 'package:flutter/material.dart';
import 'package:cashierapp_simulationukk2026/models/pelanggan_models.dart';
import 'package:cashierapp_simulationukk2026/widgets/search_bar.dart';

class EditCustomerScreen extends StatefulWidget {
  final PelangganModel customer;

  const EditCustomerScreen({Key? key, required this.customer}) : super(key: key);

  @override
  State<EditCustomerScreen> createState() => _EditCustomerScreenState();
}

class _EditCustomerScreenState extends State<EditCustomerScreen> {
  late TextEditingController nameController;
  late TextEditingController addressController;
  late TextEditingController phoneController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.customer.namaPelanggan);
    addressController = TextEditingController(text: widget.customer.alamat ?? '');
    phoneController = TextEditingController(text: widget.customer.nomorTelepon ?? '');
  }

  @override
  void dispose() {
    nameController.dispose();
    addressController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  void _updateCustomer() {
    if (_formKey.currentState!.validate()) {
      final updatedCustomer = PelangganModel(
        pelangganID: widget.customer.pelangganID,
        namaPelanggan: nameController.text,
        alamat: addressController.text.isEmpty ? null : addressController.text,
        nomorTelepon: phoneController.text.isEmpty ? null : phoneController.text,
      );

      // TODO: Update ke database

      Navigator.pop(context, updatedCustomer);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1D2E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF252837),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Customer Management',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Bar (read only, for display only)
              CustomSearchBar(
                hintText: 'Search Member',
                readOnly: true,
                backgroundColor: const Color(0xFF252837),
              ),
              const SizedBox(height: 16),

              // Toggle Buttons
              Row(
                children: [
                  Expanded(
                    child: _buildToggleButton('All Member', Icons.people, false),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildToggleButton('Edit Member', Icons.edit, true),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Form Title
              const Text(
                'Edit Member',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),

              // Full Name
              const Text(
                'Full Name',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
              const SizedBox(height: 8),
              _buildTextField(
                controller: nameController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter full name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Address
              const Text(
                'Addresse',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
              const SizedBox(height: 8),
              _buildTextField(controller: addressController),
              const SizedBox(height: 20),

              // Phone Number
              const Text(
                'No Handphone',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
              const SizedBox(height: 8),
              _buildTextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 40),

              // Update Button
              Center(
                child: SizedBox(
                  width: 160,
                  child: ElevatedButton(
                    onPressed: _updateCustomer,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE8A547),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: const Text(
                      'Update',
                      style: TextStyle(
                        fontSize: 16,
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
    );
  }

  Widget _buildToggleButton(String text, IconData icon, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFE8A547) : const Color(0xFF252837),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isSelected ? Colors.black : Colors.grey,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: isSelected ? Colors.black : Colors.grey,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFF3E4A5E),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
    );
  }
}