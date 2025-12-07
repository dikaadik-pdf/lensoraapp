import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cashierapp_simulationukk2026/models/produk_model.dart';
import 'package:cashierapp_simulationukk2026/models/stoklog_models.dart';
import 'package:cashierapp_simulationukk2026/widgets/search_bar.dart';
import 'package:cashierapp_simulationukk2026/screens/managementstock/update.dart';

class ManagementStockScreen extends StatefulWidget {
  const ManagementStockScreen({Key? key}) : super(key: key);

  @override
  State<ManagementStockScreen> createState() => _ManagementStockScreenState();
}

class _ManagementStockScreenState extends State<ManagementStockScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'Camera';
  List<ProdukModel> _products = [];
  List<ProdukModel> _filteredProducts = [];
  List<StokLogModel> _stockHistory = [];
  Map<int, Map<String, dynamic>> _productCache = {};
  bool _isLoading = true;

  final List<Map<String, dynamic>> _categories = [
    {'name': 'Camera', 'icon': Icons.camera_alt},
    {'name': 'Lens', 'icon': Icons.camera},
    {'name': 'Equipment', 'icon': Icons.settings},
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    await Future.wait([
      _loadProducts(),
      _loadStockHistory(),
    ]);
    setState(() => _isLoading = false);
  }

  Future<void> _loadProducts() async {
    try {
      final response = await Supabase.instance.client
          .from('produk')
          .select()
          .eq('kategori', _selectedCategory);

      _products = (response as List)
          .map((e) => ProdukModel.fromJson(e))
          .toList();

      _filteredProducts = _products;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading products: $e')),
        );
      }
    }
  }

  Future<void> _loadStockHistory() async {
    try {
      final response = await Supabase.instance.client
          .from('stok_log')
          .select('*, produk!inner(produkid, namaproduk, kategori)')
          .order('tanggal', ascending: false)
          .limit(10);

      _stockHistory = (response as List)
          .map((e) => StokLogModel.fromJson(e))
          .toList();

      for (var item in response) {
        if (item['produk'] != null) {
          final produkData = item['produk'];
          _productCache[produkData['produkid']] = {
            'namaproduk': produkData['namaproduk'],
            'kategori': produkData['kategori'],
          };
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading history: $e')),
        );
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

  String _getStockStatus() {
    if (_products.isEmpty) return 'No products';
    
    int outOfStock = _products.where((p) => p.stok == 0).length;
    int lowStock = _products.where((p) => p.stok > 0 && p.stok <= 5).length;
    
    if (outOfStock > 0) {
      return '$outOfStock Product Stocks Running Low/Out of Stock';
    } else if (lowStock > 0) {
      return '$lowStock Product Stocks Running Low/Out of Stock';
    } else {
      return 'All Stocks Are Safe';
    }
  }

  Color _getStockStatusColor() {
    if (_products.isEmpty) return const Color(0xFFA2FF5B).withOpacity(0.45);
    
    int outOfStock = _products.where((p) => p.stok == 0).length;
    int lowStock = _products.where((p) => p.stok > 0 && p.stok <= 5).length;
    
    if (outOfStock > 0) {
      return const Color(0xFFBF0505).withOpacity(0.45);
    } else if (lowStock > 0) {
      return const Color(0xFFE4B169).withOpacity(0.45);
    } else {
      return const Color(0xFFA2FF5B).withOpacity(0.45);
    }
  }

  IconData _getStockStatusIcon() {
    if (_products.isEmpty) return Icons.check_circle;
    
    int outOfStock = _products.where((p) => p.stok == 0).length;
    int lowStock = _products.where((p) => p.stok > 0 && p.stok <= 5).length;
    
    if (outOfStock > 0) {
      return Icons.error;
    } else if (lowStock > 0) {
      return Icons.warning;
    } else {
      return Icons.check_circle;
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
                  Text(
                    'Management Stock',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // STOCK STATUS NOTIFICATION
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                width: 365,
                height: 75,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getStockStatusColor(),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      _getStockStatusIcon(),
                      color: Colors.white,
                      size: 30,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _getStockStatus(),
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

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
                      _loadData();
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

            const SizedBox(height: 16),

            // PRODUCT LIST
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFE4B169),
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          ..._filteredProducts.map((product) =>
                              _buildProductCard(product)),
                          
                          const SizedBox(height: 20),
                          
                          // STOCK CHANGE HISTORY
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Stock Change History',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 12),
                          
                          Container(
                            width: 360,
                            height: 395,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2E343B),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: _stockHistory.isEmpty
                                ? Center(
                                    child: Text(
                                      'No history yet',
                                      style: GoogleFonts.poppins(
                                        color: Colors.white70,
                                      ),
                                    ),
                                  )
                                : ListView.separated(
                                    itemCount: _stockHistory.length,
                                    separatorBuilder: (_, __) =>
                                        const SizedBox(height: 10),
                                    itemBuilder: (context, index) =>
                                        _buildHistoryItem(_stockHistory[index]),
                                  ),
                          ),
                          
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(ProdukModel product) {
    Color indicatorColor;
    if (product.stok == 0) {
      indicatorColor = const Color(0xFFBF0505);
    } else if (product.stok <= 5) {
      indicatorColor = const Color(0xFFE4B169);
    } else {
      indicatorColor = const Color(0xFFA2FF5B);
    }

    return Container(
      width: 360,
      height: 125,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF2E343B),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // INDICATOR
          Container(
            width: 8,
            height: double.infinity,
            decoration: BoxDecoration(
              color: indicatorColor,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          
          const SizedBox(width: 12),
          
          // CONTENT
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  product.namaProduk,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      'Stock: ',
                      style: GoogleFonts.poppins(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      '${product.stok}',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      'Min Stock: ',
                      style: GoogleFonts.poppins(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      '5',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // UPDATE BUTTON
          SizedBox(
            width: 80,
            height: 35,
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
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => UpdateStockDialog(product: product),
                );
                if (result == true) _loadData();
              },
              child: Text(
                'Update',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(StokLogModel log) {
    String productName = 'Unknown Product';
    
    if (_productCache.containsKey(log.idProduk)) {
      productName = _productCache[log.idProduk]!['namaproduk'];
    } else {
      final product = _products.firstWhere(
        (p) => p.produkID == log.idProduk,
        orElse: () => ProdukModel(
          produkID: 0,
          namaProduk: 'Unknown Product',
          kategori: '',
          harga: 0,
          stok: 0,
        ),
      );
      productName = product.namaProduk;
    }

    final isIncrease = log.perubahan > 0;
    final iconColor = isIncrease ? Colors.green : Colors.red;
    final icon = isIncrease ? Icons.arrow_upward : Icons.arrow_downward;

    return Container(
      width: 335,
      height: 90,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF25292E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // ICON
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 24,
            ),
          ),
          
          const SizedBox(width: 12),
          
          // CONTENT
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  productName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  log.keterangan ?? 'No description',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${log.tanggal.day}/${log.tanggal.month}/${log.tanggal.year} ${log.tanggal.hour}:${log.tanggal.minute.toString().padLeft(2, '0')}',
                  style: GoogleFonts.poppins(
                    color: Colors.white60,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          
          // AMOUNT
          Text(
            '${isIncrease ? '+' : ''}${log.perubahan}',
            style: GoogleFonts.poppins(
              color: iconColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}