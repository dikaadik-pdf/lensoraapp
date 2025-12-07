import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cashierapp_simulationukk2026/models/pelanggan_models.dart';
import 'package:cashierapp_simulationukk2026/screens/cashier/cartitem_models.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';

class ReceiptPage extends StatefulWidget {
  final String transactionNumber;
  final PelangganModel customer;
  final List<CartItemModel> cartItems;
  final double subtotal;
  final double discount;
  final double total;
  final String paymentMethod;
  final DateTime transactionDate;
  final double cashAmount;
  final double refund;

  const ReceiptPage({
    super.key,
    required this.transactionNumber,
    required this.customer,
    required this.cartItems,
    required this.subtotal,
    required this.discount,
    required this.total,
    required this.paymentMethod,
    required this.transactionDate,
    required this.cashAmount,
    required this.refund,
  });

  @override
  State<ReceiptPage> createState() => _ReceiptPageState();
}

class _ReceiptPageState extends State<ReceiptPage> {
  String cashierName = "";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadCashierName();
  }

  Future<void> loadCashierName() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;

      print('=== DEBUG CASHIER ===');
      print('Current User: ${user?.id}');
      print('User Email: ${user?.email}');

      if (user != null) {
        final response = await Supabase.instance.client
            .from("users")
            .select("email, role")
            .eq("id", user.id)
            .maybeSingle();

        print('Response from users table: $response');

        if (response != null && response["email"] != null) {
          setState(() {
            cashierName = response["email"];
            isLoading = false;
          });
          print('Cashier name set to: $cashierName');
        } else {
          setState(() {
            cashierName = user.email ?? "Unknown";
            isLoading = false;
          });
          print('Using auth email: ${user.email}');
        }
      } else {
        setState(() {
          cashierName = "Not Logged In";
          isLoading = false;
        });
        print('No user logged in');
      }
    } catch (e) {
      print('Error loading cashier name: $e');

      final user = Supabase.instance.client.auth.currentUser;
      setState(() {
        cashierName = user?.email ?? "Unknown";
        isLoading = false;
      });
    }
  }

  Future<void> printReceipt() async {
    final pdf = pw.Document();

    final fdate = DateFormat(
      "dd MMMM yyyy HH:mm",
    ).format(widget.transactionDate);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll57,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Text(
                  "Lensora",
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.Center(
                child: pw.Text(
                  "Capture",
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 8),

              pw.Center(
                child: pw.Text(
                  widget.transactionNumber,
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 6),

              pw.Center(
                child: pw.Text(
                  "Date: $fdate",
                  style: const pw.TextStyle(fontSize: 9),
                ),
              ),
              pw.Center(
                child: pw.Text(
                  "Cashier: $cashierName",
                  style: const pw.TextStyle(fontSize: 9),
                ),
              ),

              pw.SizedBox(height: 8),
              pw.Divider(thickness: 1),
              pw.SizedBox(height: 4),

              pw.Text(
                "Customer: ${widget.customer.namaPelanggan}",
                style: const pw.TextStyle(fontSize: 10),
              ),

              pw.SizedBox(height: 4),
              pw.Divider(thickness: 1),
              pw.SizedBox(height: 8),

              pw.Row(
                children: [
                  pw.Expanded(
                    flex: 3,
                    child: pw.Text(
                      "Item",
                      style: const pw.TextStyle(fontSize: 9),
                    ),
                  ),
                  pw.Expanded(
                    flex: 1,
                    child: pw.Text(
                      "Qty",
                      textAlign: pw.TextAlign.center,
                      style: const pw.TextStyle(fontSize: 9),
                    ),
                  ),
                  pw.Expanded(
                    flex: 2,
                    child: pw.Text(
                      "Price",
                      textAlign: pw.TextAlign.right,
                      style: const pw.TextStyle(fontSize: 9),
                    ),
                  ),
                ],
              ),

              pw.SizedBox(height: 6),

              pw.Column(
                children: widget.cartItems.map((e) {
                  return pw.Padding(
                    padding: const pw.EdgeInsets.only(bottom: 6),
                    child: pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Expanded(
                          flex: 3,
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(
                                e.product.namaProduk,
                                style: const pw.TextStyle(fontSize: 9),
                              ),
                              pw.Text(
                                "Rp ${NumberFormat('#,###', 'id_ID').format(e.product.harga)}",
                                style: const pw.TextStyle(fontSize: 8),
                              ),
                            ],
                          ),
                        ),
                        pw.Expanded(
                          flex: 1,
                          child: pw.Text(
                            "${e.quantity}x",
                            textAlign: pw.TextAlign.center,
                            style: const pw.TextStyle(fontSize: 9),
                          ),
                        ),
                        pw.Expanded(
                          flex: 2,
                          child: pw.Text(
                            "Rp ${NumberFormat('#,###', 'id_ID').format(e.subtotal)}",
                            textAlign: pw.TextAlign.right,
                            style: const pw.TextStyle(fontSize: 9),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),

              pw.SizedBox(height: 4),
              pw.Divider(thickness: 1),
              pw.SizedBox(height: 4),

              _pdfPrice("Subtotal", widget.subtotal),
              if (widget.discount > 0) _pdfPrice("Discount", widget.discount),
              pw.SizedBox(height: 4),
              _pdfPrice("Total", widget.total, bold: true),

              pw.SizedBox(height: 4),
              pw.Divider(thickness: 1),
              pw.SizedBox(height: 4),

              _pdfInfo("Payment Method", widget.paymentMethod),

              if (widget.paymentMethod == "Cash") ...[
                pw.SizedBox(height: 2),
                _pdfPrice("Cash", widget.cashAmount),
                _pdfPrice("Refund", widget.refund, bold: true),
              ],

              pw.SizedBox(height: 12),
              pw.Center(
                child: pw.Text(
                  "Thank you!",
                  style: const pw.TextStyle(fontSize: 10),
                ),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  pw.Widget _pdfPrice(String label, double amount, {bool bold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: 9,
              fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
          pw.Text(
            "Rp ${NumberFormat('#,###', 'id_ID').format(amount)}",
            style: pw.TextStyle(
              fontSize: 9,
              fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _pdfInfo(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: const pw.TextStyle(fontSize: 9)),
          pw.Text(
            value,
            style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fdate = DateFormat(
      "dd MMMM yyyy HH:mm",
    ).format(widget.transactionDate);

    return Scaffold(
      backgroundColor: const Color(0xFF25292E),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF25292E),
        elevation: 0,
        title: const Text(
          "Receipt",
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 390,
                constraints: const BoxConstraints(minHeight: 620),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E343B),
                  borderRadius: BorderRadius.circular(6),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      "assets/images/lensoralogo.png",
                      width: 80,
                      height: 80,
                    ),

                    const SizedBox(height: 16),

                    Text(
                      widget.transactionNumber,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      fdate,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      isLoading
                          ? "Cashier: Loading..."
                          : "Cashier: $cashierName",
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),

                    const SizedBox(height: 20),
                    const Divider(color: Colors.grey, thickness: 1),
                    const SizedBox(height: 12),

                    _info("Customer", widget.customer.namaPelanggan),

                    const SizedBox(height: 12),
                    const Divider(color: Colors.grey, thickness: 1),
                    const SizedBox(height: 16),
                    const Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Text(
                            "Item",
                            style: TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(
                            "Qty",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            "Price",
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),
                    ...widget.cartItems.map((item) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.product.namaProduk,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    "Rp ${NumberFormat('#,###', 'id_ID').format(item.product.harga)}",
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text(
                                "${item.quantity}x",
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                "Rp ${NumberFormat('#,###', 'id_ID').format(item.subtotal)}",
                                textAlign: TextAlign.right,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),

                    const SizedBox(height: 8),
                    const Divider(color: Colors.grey, thickness: 1),
                    const SizedBox(height: 12),

                    _price("Subtotal", widget.subtotal),
                    const SizedBox(height: 6),
                    if (widget.discount > 0) ...[
                      _price("Discount", widget.discount),
                      const SizedBox(height: 6),
                    ],
                    _price("Total", widget.total, bold: true),

                    const SizedBox(height: 12),
                    const Divider(color: Colors.grey, thickness: 1),
                    const SizedBox(height: 12),

                    _info("Payment Method", widget.paymentMethod),

                    if (widget.paymentMethod == "Cash") ...[
                      const SizedBox(height: 6),
                      _price("Cash", widget.cashAmount),
                      const SizedBox(height: 6),
                      _price("Refund", widget.refund, bold: true),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: 333,
                height: 52,
                child: ElevatedButton(
                  onPressed: printReceipt,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3A4C5E),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Print Receipt",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: 333,
                height: 52,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3A4C5E),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Close",
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

  Widget _info(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _price(String label, double val, {bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
        Text(
          "Rp ${NumberFormat('#,###', 'id_ID').format(val)}",
          style: TextStyle(
            color: Colors.white,
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}
