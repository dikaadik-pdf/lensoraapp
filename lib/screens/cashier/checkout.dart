import 'package:flutter/material.dart'; 
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cashierapp_simulationukk2026/models/pelanggan_models.dart';
import 'package:cashierapp_simulationukk2026/screens/cashier/cartitem_models.dart';
import 'package:cashierapp_simulationukk2026/widgets/notification.dart';
import 'package:cashierapp_simulationukk2026/screens/cashier/receipt.dart';

class CheckoutConfirmationDialog extends StatefulWidget {
  final PelangganModel customer;
  final List<CartItemModel> cartItems;
  final String paymentMethod;
  final double subtotal;
  final double discount;
  final double total;
  final double cashAmount;
  final double refund;

  const CheckoutConfirmationDialog({
    Key? key,
    required this.customer,
    required this.cartItems,
    required this.paymentMethod,
    required this.subtotal,
    required this.discount,
    required this.total,
    required this.cashAmount,
    required this.refund,
  }) : super(key: key);

  @override
  State<CheckoutConfirmationDialog> createState() =>
      _CheckoutConfirmationDialogState();
}

class _CheckoutConfirmationDialogState
    extends State<CheckoutConfirmationDialog> {
  bool _isProcessing = false;

  Future<void> _processCheckout() async {
    if (_isProcessing) return;

    setState(() => _isProcessing = true);

    try {
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser?.id;

      // Generate nomor transaksi
      final transactionNumber = await _generateTransactionNumber();

      // Fix null warning
      int customerId = widget.customer.pelangganID ?? 0;

      // Jika walk-in customer baru
      if (customerId == 0) {
        final customerResponse = await supabase
            .from('pelanggan')
            .insert({
              'namapelanggan': widget.customer.namaPelanggan,
              'alamat': widget.customer.alamat,
              'nomortelepon': widget.customer.nomorTelepon,
            })
            .select()
            .single();

        customerId = customerResponse['pelangganid'];
      }

      // Insert penjualan
      final saleResponse = await supabase
          .from('penjualan')
          .insert({
            'pelangganid': customerId,
            'tanggalpenjualan': DateTime.now().toIso8601String(),
            'totalharga': widget.subtotal,
            'metodepembayaran': widget.paymentMethod,
            'diskon': widget.discount,
            'grandtotal': widget.total,
            'notransaksi': transactionNumber,
            'userid': userId,
          })
          .select()
          .single();

      final saleId = saleResponse['penjualanid'];

      // Insert detailpenjualan + update stok + stok_log
      for (final item in widget.cartItems) {
        final produkID = item.product.produkID;

        await supabase.from('detailpenjualan').insert({
          'penjualanid': saleId,
          'produkid': produkID,
          'jumlahproduk': item.quantity,
          'hargasatuan': item.product.harga,
          'subtotal': item.subtotal,
        });

        final newStock = (item.product.stok ?? 0) - item.quantity;

        await supabase
            .from('produk')
            .update({'stok': newStock})
            .eq('produkid', produkID);

        await supabase.from('stok_log').insert({
          'id_produk': produkID,
          'perubahan': -item.quantity,
          'keterangan': 'Penjualan - $transactionNumber',
          'id_user': userId,
        });
      }

      if (!mounted) return;

      // Tampilkan success notification (opsional)
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => SuccessNotificationDialog(
          title: 'Payment Success!',
          message: 'Transaction has been completed successfully',
          onOkPressed: () => Navigator.pop(context),
        ),
      );

      // Langsung navigasi ke ReceiptPage
      if (!mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ReceiptPage(
            transactionNumber: transactionNumber,
            customer: PelangganModel(
              pelangganID: customerId,
              namaPelanggan: widget.customer.namaPelanggan,
              alamat: widget.customer.alamat,
              nomorTelepon: widget.customer.nomorTelepon,
            ),
            cartItems: widget.cartItems,
            subtotal: widget.subtotal,
            discount: widget.discount,
            total: widget.total,
            paymentMethod: widget.paymentMethod,
            transactionDate: DateTime.now(),
            cashAmount: widget.cashAmount,
            refund: widget.refund,
          ),
        ),
      );

      // Kembali ke cashier
      Navigator.of(context).pop({'success': true});
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error processing checkout: $e')),
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<String> _generateTransactionNumber() async {
    try {
      final response = await Supabase.instance.client
          .from('penjualan')
          .select('notransaksi')
          .order('penjualanid', ascending: false)
          .limit(1);

      if (response.isEmpty) return 'LENSCP001';

      final last = response[0]['notransaksi'] as String;
      final number = int.parse(last.substring(6)) + 1;

      return 'LENSCP${number.toString().padLeft(3, '0')}';
    } catch (e) {
      return 'LENSCP${DateTime.now().millisecondsSinceEpoch % 1000}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 310,
        height: 450,
        decoration: BoxDecoration(
          color: const Color(0xFF25292E),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  'Confirmation Checkout',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _buildInfoRow('Customer', widget.customer.namaPelanggan),
              const SizedBox(height: 12),
              _buildInfoRow(
                'Total Item',
                '${widget.cartItems.fold(0, (sum, item) => sum + item.quantity)} items',
              ),
              const SizedBox(height: 12),
              _buildInfoRow('Payment Method', widget.paymentMethod),
              const SizedBox(height: 26),
              const Divider(color: Colors.grey, thickness: 1),
              const SizedBox(height: 16),
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
                    'Rp ${widget.total.toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: Color(0xFFE4B169),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildInfoRow(
                'Payment',
                widget.paymentMethod == 'Cash'
                    ? 'Rp ${widget.cashAmount.toStringAsFixed(0)}'
                    : 'Rp ${widget.total.toStringAsFixed(0)}',
              ),
              const SizedBox(height: 8),
              if (widget.paymentMethod == 'Cash')
                _buildInfoRow(
                  'Refund',
                  widget.refund > 0
                      ? 'Rp ${widget.refund.toStringAsFixed(0)}'
                      : 'Rp 0',
                ),
              const SizedBox(height: 65),
              SizedBox(
                width: double.infinity,
                height: 40,
                child: ElevatedButton(
                  onPressed: _processCheckout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3A4C5E),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    disabledBackgroundColor: Colors.grey,
                  ),
                  child: _isProcessing
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Confirmation',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
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

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 14,
          ),
        ),
        Flexible(
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
