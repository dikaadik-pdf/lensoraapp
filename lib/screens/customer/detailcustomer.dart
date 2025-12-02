import 'package:flutter/material.dart';
import 'package:cashierapp_simulationukk2026/models/pelanggan_models.dart';
import 'package:cashierapp_simulationukk2026/services/helpercustomer.dart';
import 'package:intl/intl.dart';

class DetailCustomerScreen extends StatefulWidget {
  final PelangganModel customer;

  const DetailCustomerScreen({Key? key, required this.customer})
      : super(key: key);

  @override
  State<DetailCustomerScreen> createState() => _DetailCustomerScreenState();
}

class _DetailCustomerScreenState extends State<DetailCustomerScreen> {
  List<TransactionHistory> transactions = [];
  double totalAmount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    setState(() => _isLoading = true);

    try {
      // Load transaksi dari database
      final response = await PelangganDatabaseHelper.getTransactionHistory(
        widget.customer.pelangganID!);


      // Parse data ke model TransactionHistory
      List<TransactionHistory> loadedTransactions = [];
      double total = 0;

      for (var transaksi in response) {
        // Format tanggal
        DateTime date = DateTime.parse(transaksi['tanggalpenjualan']);
        String formattedDate = DateFormat('dd/MM/yyyy HH:mm').format(date);

        // Parse detail items
        List<TransactionItem> items = [];
        for (var detail in transaksi['details']) {
          items.add(TransactionItem(
            name: detail['produk']['namaproduk'],
            code: 'ID: ${detail['detailid']}',
            quantity: detail['jumlahproduk'],
            price: (detail['subtotal'] as num).toDouble(),
          ));
        }

        loadedTransactions.add(TransactionHistory(
          date: formattedDate,
          transactionNumber: transaksi['notransaksi'],
          items: items,
          grandTotal: (transaksi['grandtotal'] as num).toDouble(),
        ));

        total += (transaksi['grandtotal'] as num).toDouble();
      }

      setState(() {
        transactions = loadedTransactions;
        totalAmount = total;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading transactions: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF25292E),
      body: SafeArea(
        child: Column(
          children: [
            /// HEADER WITH BACK BUTTON
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Text(
                      'History ${widget.customer.namaPelanggan}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            /// TRANSACTION LIST
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFE4B169),
                      ),
                    )
                  : transactions.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(
                                Icons.receipt_long_outlined,
                                size: 80,
                                color: Colors.white38,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'No transaction history',
                                style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          color: const Color(0xFFE4B169),
                          onRefresh: _loadTransactions,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: transactions.length,
                            itemBuilder: (context, index) {
                              return _buildTransactionCard(transactions[index]);
                            },
                          ),
                        ),
            ),

            /// BOTTOM SECTION - Total and Back Button
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF2E343B),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Rp ${_formatCurrency(totalAmount)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE4B169),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Back',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionCard(TransactionHistory transaction) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2E343B),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Transaction Number and Date
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                transaction.transactionNumber,
                style: const TextStyle(
                  color: Color(0xFFE4B169),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                transaction.date,
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Items
          ...transaction.items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            item.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Text(
                          'x${item.quantity}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          item.code,
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          'Rp ${_formatCurrency(item.price)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )),

          // Divider
          const Divider(color: Colors.white24, height: 20, thickness: 1),

          // Transaction Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Rp ${_formatCurrency(transaction.grandTotal)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatCurrency(double amount) {
    return amount
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }
}

// Helper Classes
class TransactionHistory {
  final String date;
  final String transactionNumber;
  final List<TransactionItem> items;
  final double grandTotal;

  TransactionHistory({
    required this.date,
    required this.transactionNumber,
    required this.items,
    required this.grandTotal,
  });
}

class TransactionItem {
  final String name;
  final String code;
  final int quantity;
  final double price;

  TransactionItem({
    required this.name,
    required this.code,
    required this.quantity,
    required this.price,
  });
}