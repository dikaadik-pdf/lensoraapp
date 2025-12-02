import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cashierapp_simulationukk2026/models/produk_model.dart';
import 'package:cashierapp_simulationukk2026/widgets/search_bar.dart';
import 'addproduct.dart';
import 'editproduct.dart';
import 'package:cashierapp_simulationukk2026/widgets/confirm_dialog.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({Key? key}) : super(key: key);

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'Camera';
  List<ProdukModel> _products = [];
  List<ProdukModel> _filteredProducts = [];
  bool _isLoading = true;

  final List<Map<String, dynamic>> _categories = [
    {'name': 'Camera', 'icon': Icons.camera_alt},
    {'name': 'Lens', 'icon': Icons.camera},
    {'name': 'Equipment', 'icon': Icons.settings},
  ];

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);
    try {
      final response = await Supabase.instance.client
          .from('produk')
          .select()
          .eq('kategori', _selectedCategory);

      _products = (response as List)
          .map((e) => ProdukModel.fromJson(e))
          .toList();

      _filteredProducts = _products;

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _filterProducts(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredProducts = _products;
      } else {
        _filteredProducts = _products
            .where((p) =>
                p.namaProduk.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  Future<void> _deleteProduct(int produkID) async {
    try {
      await Supabase.instance.client
          .from('produk')
          .delete()
          .eq('produkid', produkID);

      _loadProducts();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting product: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF25292E),
      body: SafeArea(
        child: Column(
          children: [
            // HEADER
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text(
                    'Product',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // SEARCH BAR
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF2E343B),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.4),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    )
                  ],
                ),
                child: CustomSearchBar(
                  controller: _searchController,
                  onChanged: _filterProducts,
                  hintText: 'Search Product',
                ),
              ),
            ),

            const SizedBox(height: 16),

            // CATEGORY BUTTONS
            SizedBox(
              height: 38,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _categories.map((category) {
                  final isSelected = _selectedCategory == category['name'];
                  return GestureDetector(
                    onTap: () {
                      setState(() => _selectedCategory = category['name']);
                      _loadProducts();
                    },
                    child: Container(
                      width: 95,
                      height: 32,
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFFE4B169)
                            : const Color(0xFF2E343B),
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.4),
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(category['icon'], color: Colors.white, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            category['name'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 10),

            // PRODUCT GRID
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFE4B169),
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 20,
                        crossAxisSpacing: 20,
                        childAspectRatio: 170 / 250,
                      ),
                      itemCount: _filteredProducts.length,
                      itemBuilder: (context, index) =>
                          _buildProductCard(_filteredProducts[index]),
                    ),
            ),

            // ADD BUTTON
            Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: Container(
                width: 160,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFFE6E6E6),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.4),
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    )
                  ],
                ),
                child: TextButton.icon(
                  onPressed: () async {
                    final result = await showDialog<bool>(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => const AddProductDialog(),
                    );
                    if (result == true) _loadProducts();
                  },
                  icon: const Icon(Icons.add, color: Color(0xFF2E343B)),
                  label: const Text(
                    'Add Product',
                    style: TextStyle(
                      color: Color(0xFF2E343B),
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =====================================================================
  // PRODUCT CARD (SUDAH DIRAPIIN)
  // =====================================================================
  Widget _buildProductCard(ProdukModel product) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2E343B),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.45),
            blurRadius: 8,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // IMAGE
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Container(
              height: 120,
              width: double.infinity,
              color: Colors.grey[850],
              child: product.fotoUrl != null
                  ? Image.network(
                      product.fotoUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.broken_image, color: Colors.grey),
                    )
                  : const Center(
                      child:
                          Icon(Icons.image_not_supported, color: Colors.grey),
                    ),
            ),
          ),

          // CONTENT
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // NAME
                Text(
                  product.namaProduk,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 3),

                // PRICE
                Text(
                  'Rp ${product.harga.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),

                const SizedBox(height: 6),

                // STOCK BADGE
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE4B169),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Stock : ${product.stok}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // BUTTON ROW
                Row(
                  children: [
                    // EDIT
                    Expanded(
                      child: SizedBox(
                        height: 30,
                        child: TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor: const Color(0xFFE4B169),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            padding: EdgeInsets.zero,
                          ),
                          onPressed: () async {
                            final result = await showDialog<bool>(
                              barrierDismissible: false,
                              context: context,
                              builder: (context) =>
                                  EditProductDialog(product: product),
                            );
                            if (result == true) _loadProducts();
                          },
                          child: const Text(
                            'Edit',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    // DELETE
                    Expanded(
                      child: SizedBox(
                        height: 30,
                        child: TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor: const Color(0xFFBF0505),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            padding: EdgeInsets.zero,
                          ),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (_) => ConfirmationDialog(
                                logoAssetPath: "assets/images/lensoralogo.png",
                                message: "Are You Sure About Delete Product?",
                                onNoPressed: () => Navigator.pop(context),
                                onYesPressed: () {
                                  Navigator.pop(context);
                                  _deleteProduct(product.produkID);
                                },
                              ),
                            );
                          },
                          child: const Text(
                            'Delete',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
