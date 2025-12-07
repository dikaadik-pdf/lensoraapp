import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cashierapp_simulationukk2026/models/produk_model.dart';
import 'package:cashierapp_simulationukk2026/widgets/notification.dart';
import 'package:cashierapp_simulationukk2026/widgets/confirm_dialog.dart';

class EditProductDialog extends StatefulWidget {
  final ProdukModel product;

  const EditProductDialog({super.key, required this.product});

  @override
  State<EditProductDialog> createState() => _EditProductDialogState();
}

class _EditProductDialogState extends State<EditProductDialog> {
  late TextEditingController _namaController;
  late TextEditingController _hargaController;
  late TextEditingController _stokController;

  Uint8List? _imageBytes;
  bool _loading = false;
  late String _selectedCategory;
  final List<String> _categories = ['Camera', 'Lens', 'Equipment'];

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController(text: widget.product.namaProduk);
    _hargaController = TextEditingController(text: widget.product.harga.toString());
    _stokController = TextEditingController(text: widget.product.stok.toString());
    _selectedCategory = widget.product.kategori;
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() => _imageBytes = bytes);
    }
  }

  Widget _label(String text) {
    return Align(
      alignment: Alignment.center,
      child: Container(
        width: 300,
        padding: const EdgeInsets.only(left: 5),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
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
        keyboardType: number ? TextInputType.number : TextInputType.text,
        style: const TextStyle(color: Colors.white),
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 14),
          hintStyle: TextStyle(color: Colors.white38),
        ),
      ),
    );
  }

  void _confirmUpdateProduct() {
    if (_namaController.text.isEmpty ||
        _hargaController.text.isEmpty ||
        _stokController.text.isEmpty) {
      _showError('Please fill all fields!');
      return;
    }

    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (_) => ConfirmationDialog(
        logoAssetPath: "assets/images/lensoralogo.png",
        message: "Are You Sure About Updating This Product?",
        onNoPressed: () => Navigator.pop(context),
        onYesPressed: () {
          Navigator.pop(context); // Close confirmation
          _updateProduct();
        },
      ),
    );
  }

  Future<void> _updateProduct() async {
    try {
      setState(() => _loading = true);

      String? publicUrl = widget.product.fotoUrl;

      if (_imageBytes != null) {
        final fileName = "produk_${DateTime.now().millisecondsSinceEpoch}.jpg";
        final supabase = Supabase.instance.client;

        await supabase.storage.from('produk-images').uploadBinary(
              fileName,
              _imageBytes!,
              fileOptions: const FileOptions(contentType: 'image/jpeg'),
            );

        publicUrl = supabase.storage.from('produk-images').getPublicUrl(fileName);
      }

      await Supabase.instance.client.from('produk').update({
        'namaproduk': _namaController.text.trim(),
        'kategori': _selectedCategory,
        'harga': double.tryParse(_hargaController.text) ?? 0,
        'stok': int.tryParse(_stokController.text) ?? 0,
        'fotourl': publicUrl,
      }).eq('produkid', widget.product.produkID);

      if (mounted) {
        setState(() => _loading = false);
        
        // Show success notification on top of edit dialog
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (notifContext) => SuccessNotificationDialog(
            message: "Product updated\nsuccessfully!",
            onOkPressed: () {
              Navigator.of(notifContext).pop(); // Close notification
              Navigator.of(context).pop(true); // Close edit dialog
            },
          ),
        );
      }
    } catch (e) {
      setState(() => _loading = false);
      _showError("Failed: $e");
    }
  }

  void _showError(String msg) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF2C3E50),
        content: Text(msg, style: const TextStyle(color: Colors.white70)),
      ),
    );
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
                const Text(
                  "Edit Product",
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 20),

                _label("Product Image"),
                const SizedBox(height: 6),

                Align(
                  alignment: Alignment.center,
                  child: Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: GestureDetector(
                      onTap: pickImage,
                      child: Container(
                        width: 300,
                        height: 160,
                        decoration: BoxDecoration(
                          color: const Color(0xFF3A4C5E),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: _imageBytes != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.memory(_imageBytes!, fit: BoxFit.cover),
                              )
                            : widget.product.fotoUrl != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(
                                      widget.product.fotoUrl!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => _placeholder(),
                                    ),
                                  )
                                : _placeholder(),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                _label("Name of Product"),
                const SizedBox(height: 5),
                Align(alignment: Alignment.center, child: _inputField(_namaController)),

                const SizedBox(height: 12),

                _label("Category"),
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
                      child: DropdownButton(
                        value: _selectedCategory,
                        dropdownColor: const Color(0xFF2E343B),
                        iconEnabledColor: Colors.white,
                        style: const TextStyle(color: Colors.white),
                        items: _categories
                            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                            .toList(),
                        onChanged: (v) => setState(() => _selectedCategory = v!),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                _label("Price"),
                const SizedBox(height: 5),
                Align(alignment: Alignment.center, child: _inputField(_hargaController, number: true)),

                const SizedBox(height: 12),

                _label("Stock"),
                const SizedBox(height: 5),
                Align(alignment: Alignment.center, child: _inputField(_stokController, number: true)),

                const SizedBox(height: 25),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 100,
                      height: 35,
                      child: ElevatedButton(
                        onPressed: _loading ? null : () => Navigator.pop(context, false),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD32F2F),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text("Cancel", style: TextStyle(color: Colors.white)),
                      ),
                    ),
                    const SizedBox(width: 20),

                    SizedBox(
                      width: 100,
                      height: 35,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _confirmUpdateProduct,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFA500),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: _loading
                            ? const SizedBox(
                                height: 16,
                                width: 16,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ))
                            : const Text("Update", style: TextStyle(color: Colors.white)),
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

  Widget _placeholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Icon(Icons.cloud_upload_outlined, size: 40, color: Colors.white54),
        SizedBox(height: 6),
        Text("Upload a File Here", style: TextStyle(color: Colors.white70)),
      ],
    );
  }
}