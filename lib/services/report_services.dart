import 'package:supabase_flutter/supabase_flutter.dart';

class ReportService {
  static final _supabase = Supabase.instance.client;

  // Get Product Report
  static Future<List<Map<String, dynamic>>> getProductReport({
    required String period,
  }) async {
    try {
      DateTime startDate;
      DateTime endDate = DateTime.now();

      switch (period.toLowerCase()) {
        case 'daily':
          startDate = DateTime(endDate.year, endDate.month, endDate.day);
          break;
        case 'weekly':
          startDate = endDate.subtract(const Duration(days: 7));
          break;
        case 'monthly':
          startDate = DateTime(endDate.year, endDate.month, 1);
          break;
        default:
          startDate = DateTime(endDate.year, endDate.month, endDate.day);
      }

      final response = await _supabase
          .from('penjualan')
          .select('''
            penjualanid,
            notransaksi,
            tanggalpenjualan,
            totalharga,
            diskon,
            grandtotal,
            pelanggan!inner(namapelanggan),
            users!inner(email),
            detailpenjualan!inner(
              produkid,
              jumlahproduk,
              hargasatuan,
              subtotal,
              produk!inner(namaproduk, kategori)
            )
          ''')
          .gte('tanggalpenjualan', startDate.toIso8601String())
          .lte('tanggalpenjualan', endDate.toIso8601String())
          .order('tanggalpenjualan', ascending: false);

      List<Map<String, dynamic>> productReports = [];

      for (var sale in response) {
        for (var detail in sale['detailpenjualan']) {
          productReports.add({
            'no_transaksi': sale['notransaksi'],
            'product_name': detail['produk']['namaproduk'],
            'quantity': detail['jumlahproduk'],
            'price': detail['hargasatuan'],
            'subtotal': detail['subtotal'],
            'tanggal': DateTime.parse(sale['tanggalpenjualan']),
            'customer': sale['pelanggan']['namapelanggan'],
            'kasir': sale['users']['email'],
          });
        }
      }

      return productReports;
    } catch (e) {
      throw Exception('Error loading product report: $e');
    }
  }

  // Get Customer Report
  static Future<List<Map<String, dynamic>>> getCustomerReport({
    required String period,
  }) async {
    try {
      DateTime startDate;
      DateTime endDate = DateTime.now();

      switch (period.toLowerCase()) {
        case 'daily':
          startDate = DateTime(endDate.year, endDate.month, endDate.day);
          break;
        case 'weekly':
          startDate = endDate.subtract(const Duration(days: 7));
          break;
        case 'monthly':
          startDate = DateTime(endDate.year, endDate.month, 1);
          break;
        default:
          startDate = DateTime(endDate.year, endDate.month, endDate.day);
      }

      final response = await _supabase
          .from('penjualan')
          .select('''
            penjualanid,
            pelangganid,
            tanggalpenjualan,
            grandtotal,
            pelanggan!inner(
              namapelanggan,
              alamat,
              nomortelepon
            )
          ''')
          .gte('tanggalpenjualan', startDate.toIso8601String())
          .lte('tanggalpenjualan', endDate.toIso8601String())
          .order('tanggalpenjualan', ascending: false);

      Map<int, Map<String, dynamic>> customerMap = {};

      for (var sale in response) {
        int customerId = sale['pelangganid'];

        if (customerMap.containsKey(customerId)) {
          customerMap[customerId]!['total_spending'] += sale['grandtotal'];
          customerMap[customerId]!['transaction_count'] += 1;

          DateTime lastDate = customerMap[customerId]!['last_transaction'];
          DateTime currentDate = DateTime.parse(sale['tanggalpenjualan']);

          if (currentDate.isAfter(lastDate)) {
            customerMap[customerId]!['last_transaction'] = currentDate;
          }
        } else {
          customerMap[customerId] = {
            'customer_name': sale['pelanggan']['namapelanggan'],
            'address': sale['pelanggan']['alamat'] ?? '-',
            'phone': sale['pelanggan']['nomortelepon'] ?? '-',
            'total_spending': sale['grandtotal'],
            'transaction_count': 1,
            'last_transaction': DateTime.parse(sale['tanggalpenjualan']),
          };
        }
      }

      return customerMap.values.toList();
    } catch (e) {
      throw Exception('Error loading customer report: $e');
    }
  }
}
