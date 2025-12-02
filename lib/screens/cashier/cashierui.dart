import 'package:flutter/material.dart';
import 'package:cashierapp_simulationukk2026/models/pelanggan_models.dart';
import 'package:cashierapp_simulationukk2026/models/produk_model.dart';
import 'package:cashierapp_simulationukk2026/screens/cashier/cartitem_models.dart';
import 'package:cashierapp_simulationukk2026/screens/cashier/customerselector.dart';
import 'package:cashierapp_simulationukk2026/screens/cashier/productsearch.dart';
import 'package:cashierapp_simulationukk2026/screens/cashier/checkout.dart';

class CashierScreen extends StatefulWidget {
  const CashierScreen({Key? key}) : super(key: key);

  @override
  State<CashierScreen> createState() => _CashierScreenState();
}

class _CashierScreenState extends State<CashierScreen> {
  PelangganModel? _selectedCustomer;
  List<CartItemModel> _cartItems = [];
  String _paymentMethod = 'Cash';
  double _discountPercent = 0.0;
  final TextEditingController _cashAmountController = TextEditingController();

  double get _subtotal {
    return _cartItems.fold(0.0, (sum, item) => sum + item.subtotal);
  }

  double get _discountAmount {
    return _subtotal * (_discountPercent / 100);
  }

  double get _total => _subtotal - _discountAmount;

  double get _cashAmount => double.tryParse(_cashAmountController.text) ?? 0.0;

  double get _refund {
    if (_paymentMethod == 'Cash') {
      return _cashAmount - _total;
    }
    return 0.0;
  }

  @override
  void dispose() {
    _cashAmountController.dispose();
    super.dispose();
  }

  void _selectCustomer() async {
    final customer = await showDialog<PelangganModel>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const CustomerSelectorDialog(),
    );

    if (customer != null) {
      setState(() => _selectedCustomer = customer);
    }
  }

  void _searchProduct() async {
    final product = await showDialog<ProdukModel>(
      context: context,
      builder: (context) => const ProductSearchDialog(),
    );

    if (product != null) {
      _addProductToCart(product);
    }
  }

  void _addProductToCart(ProdukModel product) {
    setState(() {
      final index = _cartItems.indexWhere(
        (item) => item.product.produkID == product.produkID,
      );

      if (index != -1) {
        _cartItems[index].incrementQuantity();
      } else {
        _cartItems.add(CartItemModel(product: product));
      }
    });
  }

  void _removeCartItem(int index) {
    setState(() => _cartItems.removeAt(index));
  }

  void _checkout() async {
    if (_selectedCustomer == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please select a customer first'),
      ));
      return;
    }

    if (_cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Cart is empty'),
      ));
      return;
    }

    if (_paymentMethod == 'Cash' && _cashAmount < _total) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Cash amount is less than total'),
      ));
      return;
    }

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (context) => CheckoutConfirmationDialog(
        customer: _selectedCustomer!,
        cartItems: _cartItems,
        paymentMethod: _paymentMethod,
        subtotal: _subtotal,
        discount: _discountAmount,
        total: _total,
        cashAmount: _cashAmount,
        refund: _refund,
      ),
    );

    if (result != null && result['success'] == true) {
      setState(() {
        _selectedCustomer = null;
        _cartItems.clear();
        _paymentMethod = 'Cash';
        _discountPercent = 0.0;
        _cashAmountController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF25292E),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(
                    top: 20, left: 16, right: 16, bottom: 16),
                child: Column(
                  children: [
                    Center(child: _buildAddProductButton()), // **DITENGAH**
                    const SizedBox(height: 16),
                    if (_cartItems.isNotEmpty) _buildCartSection(),
                    if (_cartItems.isEmpty) _buildEmptyCart(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      width: 415,
      height: 200,
      decoration: const BoxDecoration(
        color: Color(0xFF2E343B),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(25),
          bottomRight: Radius.circular(25),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child:
                      const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Cashier',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            Center(
              child: GestureDetector(
                onTap: _selectCustomer,
                child: Container(
                  width: 360,
                  height: 65,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF25292E),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Choose Customer',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _selectedCustomer?.namaPelanggan ?? 'Select Customer',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const Icon(Icons.keyboard_arrow_down, color: Colors.white),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddProductButton() {
    return Container(
      width: 360,
      height: 60,
      decoration: BoxDecoration(
        color: const Color(0xFF3A4C5E),
        borderRadius: BorderRadius.circular(20),
      ),
      child: GestureDetector(
        onTap: _searchProduct,
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_shopping_cart, color: Colors.white, size: 24),
            SizedBox(width: 12),
            Text(
              'Add Product to Cart',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartSection() {
    return Container(
      width: 345,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2E343B),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _cartItems.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = _cartItems[index];
              return _buildCartItem(item, index);
            },
          ),
          const SizedBox(height: 20),
          const Divider(color: Colors.grey, thickness: 1),
          const SizedBox(height: 16),
          _buildPriceRow('Subtotal', _subtotal),
          const SizedBox(height: 12),
          _buildDiscountRow(),
          const SizedBox(height: 12),
          _buildPriceRow('Total', _total, isTotal: true),
          const SizedBox(height: 20),

          const Text(
            'Payment Method',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildPaymentMethodButton('Cash', Icons.payments),
              _buildPaymentMethodButton('Non-Cash', Icons.credit_card),
            ],
          ),

          if (_paymentMethod == 'Cash') ...[
            const SizedBox(height: 20),
            _buildCashPaymentSection(),
          ],

          const SizedBox(height: 24),
          Center(
            child: SizedBox(
              width: 200,
              height: 45,
              child: ElevatedButton(
                onPressed: _checkout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3A4C5E),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Checkout',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(CartItemModel item, int index) {
    return Container(
      width: 315,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF3A4C5E),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start, // supaya sejajar kiri
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.product.namaProduk,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Rp ${item.product.harga.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),

                    /// **QTY BUTTON DI KIRI RATA TEKS**
                    Container(
                      width: 110,
                      height: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE4B169),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          GestureDetector(
                            onTap: () => setState(() => item.decrementQuantity()),
                            child: const Icon(Icons.remove,
                                color: Colors.white, size: 18),
                          ),
                          Text(
                            '${item.quantity}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => setState(() => item.incrementQuantity()),
                            child:
                                const Icon(Icons.add, color: Colors.white, size: 18),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              /// DELETE ICON PUTIH
              IconButton(
                onPressed: () => _removeCartItem(index),
                icon: const Icon(Icons.delete_outline, color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, double amount, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isTotal ? Colors.white : Colors.grey,
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
        Text(
          'Rp ${amount.toStringAsFixed(0)}',
          style: TextStyle(
            color: Colors.white,
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildDiscountRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Discount',
            style: TextStyle(color: Colors.grey, fontSize: 14)),
        Row(
          children: [
            Container(
              width: 70,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFF3A4C5E),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: TextField(
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                textAlign: TextAlign.right,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: '0',
                  hintStyle: TextStyle(color: Colors.grey),
                ),
                onChanged: (value) {
                  setState(() => _discountPercent = double.tryParse(value) ?? 0);
                },
              ),
            ),
            const SizedBox(width: 4),
            const Text('%', style: TextStyle(color: Colors.white)),
            const SizedBox(width: 8),
            Text(
              'Rp ${_discountAmount.toStringAsFixed(0)}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPaymentMethodButton(String method, IconData icon) {
    final isSelected = _paymentMethod == method;

    return GestureDetector(
      onTap: () {
        setState(() {
          _paymentMethod = method;
          if (method == 'Non-Cash') _cashAmountController.clear();
        });
      },
      child: Container(
        width: 135,
        height: 70,
        decoration: BoxDecoration(
          color:
              isSelected ? const Color(0xFFE4B169) : const Color(0xFF25292E),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 26, color: isSelected ? Colors.black : Colors.white),
            const SizedBox(height: 4),
            Text(
              method,
              style: TextStyle(
                color: isSelected ? Colors.black : Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCashPaymentSection() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Cash Amount',
                style: TextStyle(color: Colors.grey, fontSize: 14)),
            Container(
              width: 160,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF3A4C5E),
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: TextField(
                controller: _cashAmountController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                textAlign: TextAlign.right,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: '0',
                  hintStyle: TextStyle(color: Colors.grey),
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Refund',
                style: TextStyle(color: Colors.grey, fontSize: 14)),
            Text(
              'Rp ${_refund > 0 ? _refund.toStringAsFixed(0) : '0'}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEmptyCart() {
    return Column(
      children: [
        const SizedBox(height: 100),
        Icon(Icons.shopping_basket_outlined, size: 120, color: Colors.grey[700]),
        const SizedBox(height: 20),
        Text(
          'No Order',
          style: TextStyle(
            color: Colors.grey[500],
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
