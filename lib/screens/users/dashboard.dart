import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';

import 'package:cashierapp_simulationukk2026/screens/produk/cardproduk.dart';
import 'package:cashierapp_simulationukk2026/screens/customer/cardcustomer.dart';
import 'package:cashierapp_simulationukk2026/screens/cashier/cashierui.dart';

class DashboardScreen extends StatelessWidget {
  final String? role;

  const DashboardScreen({super.key, required this.role});

  Color get bg => const Color(0xFF25292E);
  Color get box => const Color(0xFF2E343B);
  Color get inner => const Color(0xFF25292E);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      endDrawer: CustomDrawer(role: role),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
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
                )
              ],
            ),

            const SizedBox(height: 20),

            // ================= TODAY SALES =================
            Container(
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
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
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
                        "Rp 1.934.000",
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
                          color: Colors.green.withOpacity(.2),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child:
                            const Icon(Icons.trending_up, color: Colors.green),
                      )
                    ],
                  ),
                ],
              ),
            ),

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
                _statBox("Total Stock Product", "63", "Product"),
                const SizedBox(width: 18),
                _statBox("Total Active Users", "123", "Users"),
              ],
            ),

            const SizedBox(height: 30),

            // ================= WEEKLY GRAPH =================
            _graphSection(
              title: "Weekly Report",
              child: _weeklyGraph(),
            ),

            const SizedBox(height: 30),

            // ================= MONTHLY GRAPH =================
            _graphSection(
              title: "Monthly Report",
              child: _monthlyGraph(),
            ),

            const SizedBox(height: 30),

            // ================= TX LIST =================
            _transactionSection(),
          ],
        ),
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
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Colors.white,
            ),
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
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
              child: child,
            ),
          )
        ],
      ),
    );
  }

  // ======================== WEEKLY GRAPH =========================
  Widget _weeklyGraph() {
    return LineChart(
      LineChartData(
        minX: 0,
        maxX: 6,
        minY: 0,
        maxY: 10,
        gridData: FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(show: false),
        lineBarsData: [
          LineChartBarData(
            isCurved: true,
            barWidth: 4,
            color: Colors.blueAccent,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  Colors.blueAccent.withOpacity(.30),
                  Colors.blueAccent.withOpacity(.03),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            spots: const [
              FlSpot(0, 2),
              FlSpot(1, 4),
              FlSpot(2, 3),
              FlSpot(3, 6),
              FlSpot(4, 5),
              FlSpot(5, 7),
              FlSpot(6, 9),
            ],
          ),
        ],
      ),
    );
  }

  // ======================== MONTHLY GRAPH =========================
  Widget _monthlyGraph() {
    return LineChart(
      LineChartData(
        minX: 0,
        maxX: 11,
        minY: 0,
        maxY: 10,
        gridData: FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(show: false),
        lineBarsData: [
          LineChartBarData(
            isCurved: true,
            barWidth: 4,
            color: Colors.orangeAccent,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  Colors.orangeAccent.withOpacity(.30),
                  Colors.orangeAccent.withOpacity(.03),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            spots: const [
              FlSpot(0, 3),
              FlSpot(1, 4),
              FlSpot(2, 6),
              FlSpot(3, 5),
              FlSpot(4, 7),
              FlSpot(5, 8),
              FlSpot(6, 6),
              FlSpot(7, 7),
              FlSpot(8, 9),
              FlSpot(9, 8),
              FlSpot(10, 9),
              FlSpot(11, 10),
            ],
          ),
        ],
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
          )
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

          _transactionItem(
            name: "Transaksi Berhasil!",
            product: "Kamera Fujifilm X-A7",
            amount: "Rp 2.350.000",
            payment: "Cash",
          ),

          const SizedBox(height: 12),

          _transactionItem(
            name: "Transaksi Berhasil!",
            product: "Tripod Takara ECO-173A",
            amount: "Rp 890.000",
            payment: "Non Cash",
          ),
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
          Column(
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
                style: GoogleFonts.poppins(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Text(
                  payment,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 11,
                  ),
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
          _buildDrawerItem(
            context,
            Icons.camera_alt_outlined,
            "Product",
            () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ProductListScreen(),
                ),
              );
            },
          ),
          _buildDivider(),

          // Customer
          _buildDrawerItem(
            context,
            Icons.headset_mic_outlined,
            "Customer",
            () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CustomerManagementScreen(),
                ),
              );
            },
          ),
          _buildDivider(),

          // Cashier
          _buildDrawerItem(
            context,
            Icons.shopping_bag_outlined,
            "Cashier",
            () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CashierScreen(),
                ),
              );
            },
          ),
          _buildDivider(),

          // Add New Officers (hanya untuk admin)
          if (role == "admin") ...[
            _buildDrawerItem(
              context,
              Icons.person_add_outlined,
              "Add New Officers",
              () {},
            ),
            _buildDivider(),
          ],

          // Management Store
          _buildDrawerItem(
            context,
            Icons.store_outlined,
            "Management Stock",
            () {},
          ),
          _buildDivider(),

          // Report and PIN
          _buildDrawerItem(
            context,
            Icons.print_outlined,
            "Report and Print",
            () {},
          ),
          _buildDivider(),

          // Settings
          _buildDrawerItem(
            context,
            Icons.settings_outlined,
            "Settings",
            () {},
          ),
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
            Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
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