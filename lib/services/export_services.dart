import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

class ExportService {
  static Future<void> exportToPdf({
    required List<Map<String, dynamic>> reportData,
    required String category,
    required String period,
  }) async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final now = DateTime.now();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // HEADER
            pw.Header(
              level: 0,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Sales Report - $category',
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    'Period: $period',
                    style: const pw.TextStyle(fontSize: 14),
                  ),
                  pw.Text(
                    'Generated: ${dateFormat.format(now)}',
                    style: const pw.TextStyle(fontSize: 12),
                  ),
                  pw.Divider(thickness: 2),
                ],
              ),
            ),

            pw.SizedBox(height: 20),

            // TABLE
            if (category == 'Produk') ...[
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300),
                columnWidths: {
                  0: const pw.FlexColumnWidth(3),
                  1: const pw.FlexColumnWidth(1),
                  2: const pw.FlexColumnWidth(2),
                  3: const pw.FlexColumnWidth(2),
                },
                children: [
                  // Header
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(
                      color: PdfColors.grey300,
                    ),
                    children: [
                      _buildTableCell('Product', isHeader: true),
                      _buildTableCell('Qty', isHeader: true),
                      _buildTableCell('Amount', isHeader: true),
                      _buildTableCell('Date', isHeader: true),
                    ],
                  ),
                  // Data
                  ...reportData.map((data) {
                    return pw.TableRow(
                      children: [
                        _buildTableCell(data['product_name']),
                        _buildTableCell('${data['quantity']}'),
                        _buildTableCell(
                          'Rp ${NumberFormat('#,###', 'id_ID').format(data['subtotal'])}',
                        ),
                        _buildTableCell(
                          DateFormat('dd/MM/yy').format(data['tanggal']),
                        ),
                      ],
                    );
                  }).toList(),
                ],
              ),

              pw.SizedBox(height: 20),

              // TOTAL
              pw.Container(
                alignment: pw.Alignment.centerRight,
                child: pw.Text(
                  'Total: Rp ${NumberFormat('#,###', 'id_ID').format(reportData.fold(0.0, (sum, item) => sum + item['subtotal']))}',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
            ] else ...[
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300),
                columnWidths: {
                  0: const pw.FlexColumnWidth(3),
                  1: const pw.FlexColumnWidth(2),
                  2: const pw.FlexColumnWidth(1),
                  3: const pw.FlexColumnWidth(2),
                },
                children: [
                  // Header
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(
                      color: PdfColors.grey300,
                    ),
                    children: [
                      _buildTableCell('Customer', isHeader: true),
                      _buildTableCell('Phone', isHeader: true),
                      _buildTableCell('Txn', isHeader: true),
                      _buildTableCell('Spending', isHeader: true),
                    ],
                  ),
                  // Data
                  ...reportData.map((data) {
                    return pw.TableRow(
                      children: [
                        _buildTableCell(data['customer_name']),
                        _buildTableCell(data['phone']),
                        _buildTableCell('${data['transaction_count']}'),
                        _buildTableCell(
                          'Rp ${NumberFormat('#,###', 'id_ID').format(data['total_spending'])}',
                        ),
                      ],
                    );
                  }).toList(),
                ],
              ),

              pw.SizedBox(height: 20),

              // TOTAL
              pw.Container(
                alignment: pw.Alignment.centerRight,
                child: pw.Text(
                  'Total Revenue: Rp ${NumberFormat('#,###', 'id_ID').format(reportData.fold(0.0, (sum, item) => sum + item['total_spending']))}',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
            ],
          ];
        },
      ),
    );

    // Save PDF
    await _savePdf(
      pdf,
      'Report_${category}_${period}_${now.millisecondsSinceEpoch}.pdf',
    );
  }

  static pw.Widget _buildTableCell(String text, {bool isHeader = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 12 : 10,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }

  static Future<void> _savePdf(pw.Document pdf, String fileName) async {
    // Request storage permission
    if (Platform.isAndroid) {
      var status = await Permission.storage.status;
      if (!status.isGranted) {
        await Permission.storage.request();
      }
    }

    final output = await getExternalStorageDirectory();
    final file = File('${output!.path}/$fileName');
    await file.writeAsBytes(await pdf.save());
  }

  static Future<void> printReport({
    required List<Map<String, dynamic>> reportData,
    required String category,
    required String period,
  }) async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final now = DateTime.now();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // Same content as exportToPdf
            pw.Header(
              level: 0,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Sales Report - $category',
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    'Period: $period',
                    style: const pw.TextStyle(fontSize: 14),
                  ),
                  pw.Text(
                    'Generated: ${dateFormat.format(now)}',
                    style: const pw.TextStyle(fontSize: 12),
                  ),
                  pw.Divider(thickness: 2),
                ],
              ),
            ),

            pw.SizedBox(height: 20),

            if (category == 'Produk') ...[
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300),
                columnWidths: {
                  0: const pw.FlexColumnWidth(3),
                  1: const pw.FlexColumnWidth(1),
                  2: const pw.FlexColumnWidth(2),
                  3: const pw.FlexColumnWidth(2),
                },
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(
                      color: PdfColors.grey300,
                    ),
                    children: [
                      _buildTableCell('Product', isHeader: true),
                      _buildTableCell('Qty', isHeader: true),
                      _buildTableCell('Amount', isHeader: true),
                      _buildTableCell('Date', isHeader: true),
                    ],
                  ),
                  ...reportData.map((data) {
                    return pw.TableRow(
                      children: [
                        _buildTableCell(data['product_name']),
                        _buildTableCell('${data['quantity']}'),
                        _buildTableCell(
                          'Rp ${NumberFormat('#,###', 'id_ID').format(data['subtotal'])}',
                        ),
                        _buildTableCell(
                          DateFormat('dd/MM/yy').format(data['tanggal']),
                        ),
                      ],
                    );
                  }).toList(),
                ],
              ),
            ] else ...[
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300),
                columnWidths: {
                  0: const pw.FlexColumnWidth(3),
                  1: const pw.FlexColumnWidth(2),
                  2: const pw.FlexColumnWidth(1),
                  3: const pw.FlexColumnWidth(2),
                },
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(
                      color: PdfColors.grey300,
                    ),
                    children: [
                      _buildTableCell('Customer', isHeader: true),
                      _buildTableCell('Phone', isHeader: true),
                      _buildTableCell('Txn', isHeader: true),
                      _buildTableCell('Spending', isHeader: true),
                    ],
                  ),
                  ...reportData.map((data) {
                    return pw.TableRow(
                      children: [
                        _buildTableCell(data['customer_name']),
                        _buildTableCell(data['phone']),
                        _buildTableCell('${data['transaction_count']}'),
                        _buildTableCell(
                          'Rp ${NumberFormat('#,###', 'id_ID').format(data['total_spending'])}',
                        ),
                      ],
                    );
                  }).toList(),
                ],
              ),
            ],
          ];
        },
      ),
    );
    // Print
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }
}
