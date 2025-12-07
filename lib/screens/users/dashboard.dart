import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

import 'package:cashierapp_simulationukk2026/screens/produk/cardproduk.dart';
import 'package:cashierapp_simulationukk2026/screens/customer/cardcustomer.dart';
import 'package:cashierapp_simulationukk2026/screens/cashier/cashierui.dart';
import 'package:cashierapp_simulationukk2026/screens/managementstock/managstock.dart';
import 'package:cashierapp_simulationukk2026/screens/laporan/laporanapp.dart';
import 'package:cashierapp_simulationukk2026/screens/users/logoutapp.dart';
import 'package:cashierapp_simulationukk2026/screens/officers/officerscard.dart';

class DashboardScreen extends StatefulWidget {
  final String? role;

  const DashboardScreen({super.key, required this.role});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _supabase = Supabase.instance.client;

  // Data variables
  double _todaySales = 0;
  int _totalStock = 0;
  int _totalActiveUsers = 0;
  List<double> _weeklyData = [0, 0, 0, 0, 0, 0, 0];
  Map<String, List<double>> _monthlyData = {
    'Camera': [],
    'Lens': [],
    'Equipment': [],
  };
  List<Map<String, dynamic>> _recentTransactions = [];
  bool _isLoading = true;

  // Realtime subscriptions
  RealtimeChannel? _stockChannel;
  RealtimeChannel? _customerChannel;
  RealtimeChannel? _salesChannel;
  RealtimeChannel? _detailSalesChannel;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
    _subscribeToRealtimeChanges();
  }

  @override
  void dispose() {
    _stockChannel?.unsubscribe();
    _customerChannel?.unsubscribe();
    _salesChannel?.unsubscribe();
    _detailSalesChannel?.unsubscribe();
    super.dispose();
  }

  // 🔥 REALTIME SUBSCRIPTIONS FOR ALL TABLES
  void _subscribeToRealtimeChanges() {
    // 1. Subscribe to STOCK changes (produk table)
    _stockChannel = _supabase
        .channel('stock_realtime')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'produk',
          callback: (payload) {
            debugPrint('📦 Stock changed: ${payload.eventType}');
            _loadTotalStock();
          },
        )
        .subscribe();

    // 2. Subscribe to CUSTOMER changes (pelanggan table)
    _customerChannel = _supabase
        .channel('customer_realtime')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'pelanggan',
          callback: (payload) {
            debugPrint('👥 Customer changed: ${payload.eventType}');
            _loadTotalActiveUsers();
          },
        )
        .subscribe();

    // 3. Subscribe to SALES changes (penjualan table)
    _salesChannel = _supabase
        .channel('sales_realtime')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'penjualan',
          callback: (payload) {
            debugPrint('💰 Sales changed: ${payload.eventType}');
            _loadTodaySales();
            _loadWeeklyData();
            _loadRecentTransactions();
          },
        )
        .subscribe();

    // 4. Subscribe to DETAIL SALES changes (detailpenjualan table) for monthly report
    _detailSalesChannel = _supabase
        .channel('detail_sales_realtime')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'detailpenjualan',
          callback: (payload) {
            debugPrint('📊 Detail sales changed: ${payload.eventType}');
            _loadMonthlyData();
          },
        )
        .subscribe();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    
    await Future.wait([
      _loadTodaySales(),
      _loadTotalStock(),
      _loadTotalActiveUsers(),
      _loadWeeklyData(),
      _loadMonthlyData(),
      _loadRecentTransactions(),
    ]);

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  // 1️⃣ TODAY'S SALES - REALTIME
  Future<void> _loadTodaySales() async {
    try {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      
      final response = await _supabase
          .from('penjualan')
          .select('grandtotal')
          .gte('tanggalpenjualan', startOfDay.toIso8601String())
          .lt('tanggalpenjualan', startOfDay.add(const Duration(days: 1)).toIso8601String());

      double total = 0;
      for (var item in response) {
        total += (item['grandtotal'] as num).toDouble();
      }

      if (mounted) {
        setState(() => _todaySales = total);
      }
    } catch (e) {
      debugPrint('Error loading today sales: $e');
    }
  }

  // 2️⃣ TOTAL STOCK - REALTIME
  Future<void> _loadTotalStock() async {
    try {
      final response = await _supabase
          .from('produk')
          .select('stok');

      int total = 0;
      for (var item in response) {
        total += (item['stok'] as int);
      }

      if (mounted) {
        setState(() => _totalStock = total);
      }
    } catch (e) {
      debugPrint('Error loading total stock: $e');
    }
  }

  // 3️⃣ TOTAL ACTIVE USERS (CUSTOMERS) - REALTIME
  Future<void> _loadTotalActiveUsers() async {
    try {
      final response = await _supabase
          .from('pelanggan')
          .select('pelangganid');

      if (mounted) {
        setState(() => _totalActiveUsers = response.length);
      }
    } catch (e) {
      debugPrint('Error loading total users: $e');
    }
  }

  // 4️⃣ WEEKLY DATA (Mon-Sun) - REALTIME
  Future<void> _loadWeeklyData() async {
    try {
      final now = DateTime.now();
      final monday = now.subtract(Duration(days: now.weekday - 1));
      final startOfWeek = DateTime(monday.year, monday.month, monday.day);

      final response = await _supabase
          .from('penjualan')
          .select('tanggalpenjualan, grandtotal')
          .gte('tanggalpenjualan', startOfWeek.toIso8601String());

      List<double> weekData = [0, 0, 0, 0, 0, 0, 0];

      for (var item in response) {
        final date = DateTime.parse(item['tanggalpenjualan']);
        final dayIndex = date.weekday - 1; // Mon=0, Sun=6
        if (dayIndex >= 0 && dayIndex < 7) {
          weekData[dayIndex] += (item['grandtotal'] as num).toDouble();
        }
      }

      if (mounted) {
        setState(() => _weeklyData = weekData);
      }
    } catch (e) {
      debugPrint('Error loading weekly data: $e');
    }
  }

  // 5️⃣ MONTHLY DATA (Last 3 months, by category) - REALTIME
  Future<void> _loadMonthlyData() async {
    try {
      final now = DateTime.now();
      final threeMonthsAgo = DateTime(now.year, now.month - 3, 1);

      final response = await _supabase
          .from('detailpenjualan')
          .select('penjualanid, produkid, subtotal, penjualan!inner(tanggalpenjualan), produk!inner(kategori)')
          .gte('penjualan.tanggalpenjualan', threeMonthsAgo.toIso8601String());

      // Group by category and month
      Map<String, Map<int, double>> categoryMonthly = {
        'Camera': {},
        'Lens': {},
        'Equipment': {},
      };

      for (var item in response) {
        final category = item['produk']['kategori'] as String;
        final date = DateTime.parse(item['penjualan']['tanggalpenjualan']);
        final monthKey = date.month;
        final subtotal = (item['subtotal'] as num).toDouble();

        if (categoryMonthly.containsKey(category)) {
          categoryMonthly[category]![monthKey] = 
              (categoryMonthly[category]![monthKey] ?? 0) + subtotal;
        }
      }

      // Convert to list (last 3 months)
      Map<String, List<double>> result = {};
      for (var category in ['Camera', 'Lens', 'Equipment']) {
        result[category] = [];
        for (int i = 2; i >= 0; i--) {
          final month = DateTime(now.year, now.month - i, 1).month;
          result[category]!.add(categoryMonthly[category]![month] ?? 0);
        }
      }

      if (mounted) {
        setState(() => _monthlyData = result);
      }
    } catch (e) {
      debugPrint('Error loading monthly data: $e');
    }
  }

  // 6️⃣ RECENT TRANSACTIONS (Last 2) - REALTIME
  Future<void> _loadRecentTransactions() async {
    try {
      final response = await _supabase
          .from('penjualan')
          .select('notransaksi, grandtotal, metodepembayaran, tanggalpenjualan, detailpenjualan!inner(produk!inner(namaproduk))')
          .order('tanggalpenjualan', ascending: false)
          .limit(2);

      List<Map<String, dynamic>> transactions = [];

      for (var item in response) {
        final details = item['detailpenjualan'] as List;
        final productName = details.isNotEmpty 
            ? details[0]['produk']['namaproduk'] 
            : 'Unknown Product';

        transactions.add({
          'name': 'Transaksi Berhasil!',
          'product': productName,
          'amount': item['grandtotal'],
          'payment': item['metodepembayaran'],
        });
      }

      if (mounted) {
        setState(() => _recentTransactions = transactions);
      }
    } catch (e) {
      debugPrint('Error loading recent transactions: $e');
    }
  }

  Color get bg => const Color(0xFF25292E);
  Color get box => const Color(0xFF2E343B);
  Color get inner => const Color(0xFF25292E);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      endDrawer: CustomDrawer(role: widget.role),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFE4B169)),
            )
          : RefreshIndicator(
              color: const Color(0xFFE4B169),
              onRefresh: _loadDashboardData,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ================= HEADER =================
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Dashboard",
                          style: GoogleFonts.poppins(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Builder(
                          builder: (context) => IconButton(
                            icon: const Icon(Icons.menu, color: Colors.white, size: 30),
                            onPressed: () => Scaffold.of(context).openEndDrawer(),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // ================= TODAY SALES =================
                    _buildTodaySalesCard(),

                    const SizedBox(height: 25),

                    // ================= DETAIL TITLE =================
                    Text(
                      "Detail",
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.none,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ================= STOCK + USERS =================
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _statBox("Total Stock Product", _totalStock.toString(), "Product"),
                        const SizedBox(width: 18),
                        _statBox("Total Active Customer", _totalActiveUsers.toString(), "Users"),
                      ],
                    ),

                    const SizedBox(height: 30),

                    // ================= WEEKLY GRAPH =================
                    _graphSection(title: "Weekly Report", child: _weeklyGraph()),

                    const SizedBox(height: 30),

                    // ================= MONTHLY GRAPH =================
                    _graphSection(title: "Monthly Report", child: _monthlyGraph()),

                    const SizedBox(height: 30),

                    // ================= TX LIST =================
                    _transactionSection(),
                  ],
                ),
              ),
            ),
    );
  }

  // ======================== TODAY SALES CARD =========================
  Widget _buildTodaySalesCard() {
    final isTrending = _todaySales >= 500000;
    final trendColor = isTrending ? Colors.green : Colors.red;
    final trendIcon = isTrending ? Icons.trending_up : Icons.trending_down;

    return Container(
      width: 385,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: box,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.25),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: inner,
              borderRadius: BorderRadius.circular(25),
            ),
            child: Text(
              "Today's Sales",
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w500,
                decoration: TextDecoration.none,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Rp ${NumberFormat('#,###', 'id_ID').format(_todaySales)}",
                style: GoogleFonts.poppins(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  decoration: TextDecoration.none,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: trendColor.withOpacity(.2),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Icon(
                  trendIcon,
                  color: trendColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ======================== STAT BOX =========================
  Widget _statBox(String title, String number, String subtitle) {
    return Container(
      width: 140,
      height: 210,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      decoration: BoxDecoration(
        color: box,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.25),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            number,
            style: GoogleFonts.poppins(
              fontSize: 65,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: GoogleFonts.poppins(fontSize: 13, color: Colors.white),
          ),
        ],
      ),
    );
  }

  // ======================= GRAPH SECTION =======================
  Widget _graphSection({required String title, required Widget child}) {
    return Container(
      width: 385,
      height: 255,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: box,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.25),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: inner,
              borderRadius: BorderRadius.circular(25),
            ),
            child: Text(
              title,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: inner,
                borderRadius: BorderRadius.circular(25),
              ),
              padding: const EdgeInsets.all(12),
              child: child,
            ),
          ),
        ],
      ),
    );
  }

  // ======================== WEEKLY GRAPH =========================
  Widget _weeklyGraph() {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: _weeklyData.reduce((a, b) => a > b ? a : b) * 1.2,
        barTouchData: BarTouchData(enabled: false),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                if (value.toInt() >= 0 && value.toInt() < days.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      days[value.toInt()],
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                      ),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(_weeklyData.length, (index) {
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: _weeklyData[index],
                color: Colors.blueAccent,
                width: 16,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(6),
                  topRight: Radius.circular(6),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  // ======================== MONTHLY GRAPH =========================
  Widget _monthlyGraph() {
    final now = DateTime.now();
    final months = List.generate(3, (i) {
      final month = DateTime(now.year, now.month - (2 - i), 1);
      return DateFormat('MMM').format(month);
    });

    return LineChart(
      LineChartData(
        gridData: FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < months.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      months[value.toInt()],
                      style: const TextStyle(color: Colors.white70, fontSize: 10),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        lineBarsData: [
          // Camera line
          _buildLineData(_monthlyData['Camera']!, Colors.blueAccent),
          // Lens line
          _buildLineData(_monthlyData['Lens']!, Colors.redAccent),
          // Equipment line
          _buildLineData(_monthlyData['Equipment']!, Colors.greenAccent),
        ],
      ),
    );
  }

  LineChartBarData _buildLineData(List<double> data, Color color) {
    return LineChartBarData(
      spots: List.generate(data.length, (i) => FlSpot(i.toDouble(), data[i])),
      isCurved: true,
      color: color,
      barWidth: 3,
      dotData: FlDotData(show: true),
      belowBarData: BarAreaData(
        show: true,
        color: color.withOpacity(0.15),
      ),
    );
  }

  // ===================== TRANSACTION SECTION =====================
  Widget _transactionSection() {
    return Container(
      width: 385,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: box,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.25),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: inner,
              borderRadius: BorderRadius.circular(25),
            ),
            child: Text(
              "New Transaction List",
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(height: 16),

          if (_recentTransactions.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'No transactions yet',
                  style: GoogleFonts.poppins(
                    color: Colors.white54,
                    fontSize: 14,
                  ),
                ),
              ),
            )
          else
            ..._recentTransactions.map((tx) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _transactionItem(
                    name: tx['name'],
                    product: tx['product'],
                    amount: "Rp ${NumberFormat('#,###', 'id_ID').format(tx['amount'])}",
                    payment: tx['payment'] == 'cash' ? 'Cash' : 'Non Cash',
                  ),
                )),
        ],
      ),
    );
  }

  // ======================= TRANSACTION ITEM ======================
  Widget _transactionItem({
    required String name,
    required String product,
    required String amount,
    required String payment,
  }) {
    return Container(
      width: 360,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: inner,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // LEFT
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  product,
                  style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // RIGHT
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Text(
                  payment,
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 11),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ==========================================================
//                      CUSTOM DRAWER
// ==========================================================

class CustomDrawer extends StatelessWidget {
  final String? role;

  const CustomDrawer({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF2E343B),
      width: 260,
      child: Column(
        children: [
          const SizedBox(height: 60),

          // Dashboard
          _buildDrawerItem(
            context,
            Icons.dashboard_outlined,
            "Dashboard",
            () => Navigator.pop(context),
          ),
          _buildDivider(),

          // Product
          _buildDrawerItem(context, Icons.camera_alt_outlined, "Product", () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProductListScreen()),
            );
          }),
          _buildDivider(),

          // Customer
          _buildDrawerItem(context, Icons.headset_mic_outlined, "Customer", () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const CustomerManagementScreen(),
              ),
            );
          }),
          _buildDivider(),

          // Cashier
          _buildDrawerItem(context, Icons.shopping_bag_outlined, "Cashier", () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CashierScreen()),
            );
          }),
          _buildDivider(),

          // Management Store
          _buildDrawerItem(
            context,
            Icons.store_outlined,
            "Management Stock",
            () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ManagementStockScreen(),
                ),
              );
            },
          ),

          // Report and PIN
          _buildDrawerItem(
            context,
            Icons.print_outlined,
            "Report and Print",
            () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ReportPrintScreen()),
              );
            },
          ),
          _buildDivider(),

          // Add New Officers
          _buildDrawerItem(
            context,
            Icons.person_add_outlined,
            "Add New Officers",
            () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AddNewOfficersScreen(),
                ),
              );
            },
          ),
          _buildDivider(),

          // Settings
          _buildDrawerItem(context, Icons.settings_outlined, "Settings", () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(width: 16),
            Text(
              title,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 1,
      color: Colors.white.withOpacity(0.1),
    );
  }
}