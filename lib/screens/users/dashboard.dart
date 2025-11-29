import 'package:flutter/material.dart';
import 'package:cashierapp_simulationukk2026/screens/produk/cardproduk.dart';
import 'package:cashierapp_simulationukk2026/screens/customer/cardcustomer.dart';
import 'package:cashierapp_simulationukk2026/widgets/weekly_charts.dart';
import 'package:cashierapp_simulationukk2026/widgets/monthly_charts.dart';

class DashboardScreen extends StatelessWidget {
  final String? role; // WAJIB

  const DashboardScreen({Key? key, required this.role}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF252837),
        elevation: 0,
        title: Text('Dashboard ($role)'),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: CustomDrawer(role: role), // lempar role ke drawer
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // TODAY SALES
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF252837),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Today's Sales",
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(
                            Icons.trending_up,
                            color: Colors.green,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Rp 1.934.000',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // STAT CARDS
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Total Barang\nTerjual',
                      '63',
                      'Product',
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      'Total Artikel\nTerjual',
                      '123',
                      'Artikel',
                      Colors.purple,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // WEEKLY REPORT
              const Text(
                'Weekly Report',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 16),
              Container(
                height: 220,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF252837),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const WeeklyBarChart(values: [4, 6, 8, 3, 10, 7, 5]),
              ),

              const SizedBox(height: 24),

              // MONTHLY REPORT
              const Text(
                'Monthly Report',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 16),
              Container(
                height: 220,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF252837),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: MonthlyLineChart(
                  values: [12, 18, 24, 40, 55, 63, 70, 90, 110, 105, 120, 150],
                ),
              ),

              const SizedBox(height: 24),

              // TRANSACTION LIST
              const Text(
                'New Transaction List',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 16),
              _buildTransactionItem('Transaksi-JH2004J', 'Rp 2.500.000', 'Lunas'),
              _buildTransactionItem('Transaksi-MH1003H', 'Rp 690.000', 'Lunas'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, String subtitle, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF252837),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey, height: 1.4)),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 4),
          Text(subtitle, style: TextStyle(fontSize: 12, color: color)),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(String id, String amount, String status) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF252837),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(id, style: const TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w500)),
            const SizedBox(height: 4),
            Text(amount, style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
          ]),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: Colors.green.withOpacity(0.2), borderRadius: BorderRadius.circular(6)),
            child: Text(status, style: const TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

/// ============================================
/// CUSTOM DRAWER
/// ============================================
class CustomDrawer extends StatelessWidget {
  final String? role;

  const CustomDrawer({Key? key, required this.role}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF252837),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const SizedBox(height: 50),
          drawerItem(context, Icons.dashboard, "Dashboard", true, () => Navigator.pop(context)),
          drawerItem(context, Icons.inventory_2, "Product", false, () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (_) => const ProductListScreen()));
          }),
          drawerItem(context, Icons.people, "Customer", false, () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomerManagementScreen()));
          }),
          drawerItem(context, Icons.account_balance_wallet, "Cashier", false, () {}),

          if (role == "admin")
            drawerItem(context, Icons.person_add, "Add New Officers", false, () {}),

          drawerItem(context, Icons.assessment, "Management Store", false, () {}),
          drawerItem(context, Icons.bar_chart, "Report and PIN", false, () {}),
          drawerItem(context, Icons.settings, "Settings", false, () {}),
        ],
      ),
    );
  }

  Widget drawerItem(BuildContext ctx, IconData icon, String title, bool selected, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: selected ? const Color(0xFF6C63FF).withOpacity(0.2) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(icon, color: selected ? const Color(0xFF6C63FF) : Colors.grey),
        title: Text(title, style: TextStyle(color: selected ? Colors.white : Colors.grey, fontWeight: selected ? FontWeight.w600 : FontWeight.normal)),
        onTap: onTap,
      ),
    );
  }
}