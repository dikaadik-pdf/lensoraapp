import 'package:flutter/material.dart';
import 'package:cashierapp_simulationukk2026/models/pelanggan_models.dart';
import 'package:cashierapp_simulationukk2026/services/helpercustomer.dart';
import 'package:cashierapp_simulationukk2026/widgets/search_bar.dart';
import 'addcustomer.dart';
import 'editcustomer.dart';
import 'detailcustomer.dart';

class CustomerManagementScreen extends StatefulWidget {
  const CustomerManagementScreen({Key? key}) : super(key: key);

  @override
  State<CustomerManagementScreen> createState() =>
      _CustomerManagementScreenState();
}

class _CustomerManagementScreenState extends State<CustomerManagementScreen> {
  bool showAllMember = true;
  TextEditingController searchController = TextEditingController();
  List<PelangganModel> customers = [];
  List<PelangganModel> filteredCustomers = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCustomers();
    searchController.addListener(_filterCustomers);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCustomers() async {
    setState(() => _isLoading = true);
    try {
      final data = await PelangganDatabaseHelper.getAllPelanggan();
      if (mounted) {
        setState(() {
          customers = data;
          filteredCustomers = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading customers: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _filterCustomers() {
    String q = searchController.text.toLowerCase();
    setState(() {
      filteredCustomers = customers.where((c) {
        return c.namaPelanggan.toLowerCase().contains(q) ||
            (c.nomorTelepon?.toLowerCase().contains(q) ?? false) ||
            (c.alamat?.toLowerCase().contains(q) ?? false);
      }).toList();
    });
  }

  void _navigateToAddCustomer() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (c) => const AddCustomerScreen()),
    );
    if (result == true && mounted) {
      _loadCustomers();
    }
  }

  void _navigateToEditCustomer(PelangganModel c) async {
    final result = await showGeneralDialog<bool>(
      context: context,
      barrierDismissible: false, // Prevent dismiss by tapping outside
      barrierLabel: '',
      barrierColor: Colors.black.withOpacity(0.3),
      transitionDuration: const Duration(milliseconds: 150),
      pageBuilder: (context, anim1, anim2) {
        return EditCustomerDialog(customer: c);
      },
    );

    // Jika result == true, berarti data berhasil diupdate
    if (result == true && mounted) {
      // Reload data customers
      await _loadCustomers();
      
      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Customer updated successfully'),
            backgroundColor: Color(0xFFE4B169),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _navigateToDetailCustomer(PelangganModel c) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DetailCustomerScreen(customer: c)),
    );
  }

  // ================== UI WIDGETS ==================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF25292E),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchBar(),
            const SizedBox(height: 16),
            _buildToggleRow(),
            const SizedBox(height: 10),
            _buildCustomerList(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const Text(
            "Customer Management",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: CustomSearchBar(
        hintText: "Search Member",
        controller: searchController,
        backgroundColor: const Color(0xFF2E343B),
      ),
    );
  }

  Widget _buildToggleRow() {
    return SizedBox(
      height: 38,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildToggle("All Member", Icons.people, showAllMember, () {
            setState(() => showAllMember = true);
          }),
          const SizedBox(width: 12),
          _buildToggle("Add New", Icons.person_add, !showAllMember, _navigateToAddCustomer),
        ],
      ),
    );
  }

  Widget _buildCustomerList() {
    if (_isLoading) {
      return const Expanded(
        child: Center(
          child: CircularProgressIndicator(
            color: Color(0xFFE4B169),
          ),
        ),
      );
    } else if (filteredCustomers.isEmpty) {
      return const Expanded(
        child: Center(
          child: Text(
            'No customers found',
            style: TextStyle(color: Colors.white54, fontSize: 16),
          ),
        ),
      );
    } else {
      return Expanded(
        child: RefreshIndicator(
          color: const Color(0xFFE4B169),
          onRefresh: _loadCustomers,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filteredCustomers.length,
            itemBuilder: (_, i) => _buildCustomerCard(filteredCustomers[i]),
          ),
        ),
      );
    }
  }

  Widget _buildToggle(String text, IconData icon, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        height: 40,
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFE4B169) : const Color(0xFF2E343B),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? const Color(0xFFE4B169) : Colors.white24,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: Colors.white),
            const SizedBox(width: 6),
            Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerCard(PelangganModel c) {
    return Container(
      width: 360,
      height: 180,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
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
          Text(
            c.namaPelanggan,
            style: const TextStyle(
                color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(c.alamat ?? "-", style: const TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 4),
          Text(
            c.nomorTelepon ?? "-",
            style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                decoration: TextDecoration.underline),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Last Transaction",
                      style: TextStyle(color: Colors.white70, fontSize: 12)),
                  const SizedBox(height: 4),
                  Text(c.lastTransaction ?? "-", style: const TextStyle(color: Colors.white, fontSize: 12)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text("Total Expenditure",
                      style: TextStyle(color: Colors.white70, fontSize: 12)),
                  const SizedBox(height: 4),
                  Text(
                    c.totalExpenditure != null
                        ? "Rp ${c.totalExpenditure!.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}"
                        : "Rp 0",
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildBtn("Edit", const Color(0xFFE4B169), Colors.white,
                  () => _navigateToEditCustomer(c)),
              const SizedBox(width: 12),
              _buildBtn("Detail", const Color(0xFFBF0505), Colors.white,
                  () => _navigateToDetailCustomer(c)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBtn(String text, Color bg, Color fg, VoidCallback onTap) {
    return SizedBox(
      width: 95,
      height: 30,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 2,
        ),
        child: Text(text,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
      ),
    );
  }
}