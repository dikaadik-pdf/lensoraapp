import 'package:flutter/material.dart';
import 'package:cashierapp_simulationukk2026/models/pelanggan_models.dart';
import 'package:cashierapp_simulationukk2026/services/helpercustomer.dart';

class AddCustomerScreen extends StatefulWidget {
  const AddCustomerScreen({Key? key}) : super(key: key);

  @override
  State<AddCustomerScreen> createState() => _AddCustomerScreenState();
}

class _AddCustomerScreenState extends State<AddCustomerScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  bool _loading = false;
  bool _allMemberHovered = false;

  Future<void> _saveCustomer() async {
    if (_nameController.text.trim().isEmpty) {
      _showError('Name is required!');
      return;
    }

    setState(() => _loading = true);

    try {
      final pelanggan = PelangganModel(
        namaPelanggan: _nameController.text.trim(),
        alamat: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
        nomorTelepon: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
      );

      final result = await PelangganDatabaseHelper.addPelanggan(pelanggan);

      if (result != null) {
        if (mounted) {
          setState(() => _loading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Customer added successfully!'), backgroundColor: Colors.green),
          );
          Navigator.pop(context, true);
        }
      } else {
        throw Exception('Failed to add customer');
      }
    } catch (e) {
      setState(() => _loading = false);
      _showError('Failed to save customer: $e');
    }
  }

  void _showError(String msg) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Error'),
        content: Text(msg),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF25292E),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Custom Header with Back Button
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Customer Management',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 25),
                
                // Buttons Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // All Member Button (inactive, with hover)
                    MouseRegion(
                      onEnter: (_) => setState(() => _allMemberHovered = true),
                      onExit: (_) => setState(() => _allMemberHovered = false),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Container(
                          width: 140,
                          height: 40,
                          decoration: BoxDecoration(
                            color: _allMemberHovered 
                                ? const Color(0xFFE4B169) 
                                : const Color(0xFF2E343B),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.person,
                                color: Colors.white,
                                size: 15,
                              ),
                              const SizedBox(width: 6),
                              const Text(
                                'All Member',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Add Member Button (active - current page)
                    Container(
                      width: 140,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE4B169), // Always highlighted (current page)
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.person_add,
                            color: Colors.white,
                            size: 15,
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'Add Member',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                
                // Title
                Center(
                  child: const Text(
                    'Add a New Member',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                
                // Full Name Field
                const Text(
                  'Full Name',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF3A4C5E),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: TextField(
                    controller: _nameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      hintText: 'Enter full name',
                      hintStyle: TextStyle(color: Colors.white38, fontSize: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                
                // Address Field
                const Text(
                  'Address',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF3A4C5E),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: TextField(
                    controller: _addressController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      hintText: 'Enter address',
                      hintStyle: TextStyle(color: Colors.white38, fontSize: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                
                // Phone Number Field
                const Text(
                  'No Handphone',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF3A4C5E),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: TextField(
                    controller: _phoneController,
                    style: const TextStyle(color: Colors.white),
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      hintText: 'Enter phone number',
                      hintStyle: TextStyle(color: Colors.white38, fontSize: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                
                // Save Button
                Center(
                  child: SizedBox(
                    width: 120,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _saveCustomer,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE4B169),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        elevation: 0,
                      ),
                      child: _loading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'Save',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}