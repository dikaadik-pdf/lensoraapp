import 'package:flutter/material.dart';
import 'package:cashierapp_simulationukk2026/models/pelanggan_models.dart';
import 'package:cashierapp_simulationukk2026/widgets/search_bar.dart';
import 'package:cashierapp_simulationukk2026/screens/customer/addcustomer.dart';
import 'package:cashierapp_simulationukk2026/screens/customer/editcustomer.dart';
import 'package:cashierapp_simulationukk2026/screens/customer/detailcustomer.dart';

class CustomerManagementScreen extends StatefulWidget {
  const CustomerManagementScreen({Key? key}) : super(key: key);

  @override
  State<CustomerManagementScreen> createState() => _CustomerManagementScreenState();
}

class _CustomerManagementScreenState extends State<CustomerManagementScreen> {
  bool showAllMember = true;
  TextEditingController searchController = TextEditingController();
  List<PelangganModel> customers = [];
  List<PelangganModel> filteredCustomers = [];

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

  void _loadCustomers() {
    // TODO: Load dari database
    // Sementara data dummy
    customers = [
      PelangganModel(
        pelangganID: 1,
        namaPelanggan: 'Dhika Kucecwara',
        alamat: 'Jl. Contoh No. 123',
        nomorTelepon: '081234567890',
      ),
      PelangganModel(
        pelangganID: 2,
        namaPelanggan: 'Dhika Kucecwara',
        alamat: 'Jl. Sample No. 456',
        nomorTelepon: '081234567891',
      ),
      PelangganModel(
        pelangganID: 3,
        namaPelanggan: 'Dhika Kucecwara',
        alamat: 'Jl. Example No. 789',
        nomorTelepon: '081234567892',
      ),
    ];
    filteredCustomers = customers;
  }

  void _filterCustomers() {
    String query = searchController.text.toLowerCase();
    setState(() {
      filteredCustomers = customers.where((customer) {
        return customer.namaPelanggan.toLowerCase().contains(query) ||
            (customer.nomorTelepon?.toLowerCase().contains(query) ?? false);
      }).toList();
    });
  }

  void _navigateToAddCustomer() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddCustomerScreen()),
    );
    if (result != null && result is PelangganModel) {
      setState(() {
        customers.add(result);
        _filterCustomers();
      });
    }
  }

  void _navigateToEditCustomer(PelangganModel customer) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditCustomerScreen(customer: customer),
      ),
    );
    if (result != null && result is PelangganModel) {
      setState(() {
        int index = customers.indexWhere((c) => c.pelangganID == result.pelangganID);
        if (index != -1) {
          customers[index] = result;
          _filterCustomers();
        }
      });
    }
  }

  void _navigateToDetailCustomer(PelangganModel customer) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetailCustomerScreen(customer: customer),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1D2E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF252837),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Customer Management',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search Bar
            CustomSearchBar(
              hintText: 'Search Member',
              controller: searchController,
              backgroundColor: const Color(0xFF252837),
            ),
            const SizedBox(height: 16),

            // Toggle Buttons
            Row(
              children: [
                Expanded(
                  child: _buildToggleButton(
                    'All Member',
                    Icons.people,
                    showAllMember,
                    () => setState(() => showAllMember = true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildToggleButton(
                    'Add New',
                    Icons.person_add,
                    !showAllMember,
                    _navigateToAddCustomer,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Customer List
            Expanded(
              child: filteredCustomers.isEmpty
                  ? const Center(
                      child: Text(
                        'No customers found',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    )
                  : ListView.builder(
                      itemCount: filteredCustomers.length,
                      itemBuilder: (context, index) {
                        return _buildCustomerCard(filteredCustomers[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleButton(String text, IconData icon, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE8A547) : const Color(0xFF252837),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.black : Colors.grey,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              text,
              style: TextStyle(
                color: isSelected ? Colors.black : Colors.grey,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerCard(PelangganModel customer) {
    // TODO: Get dari database
    String lastTransaction = '20 October 2026';
    String totalExpenditure = 'Rp 41.000.000';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF252837),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            customer.namaPelanggan,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            customer.nomorTelepon ?? 'No phone',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 13,
              decoration: TextDecoration.underline,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Last Transaction',
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    lastTransaction,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Total Expenditure',
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    totalExpenditure,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _navigateToEditCustomer(customer),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE8A547),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Edit',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _navigateToDetailCustomer(customer),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE74C3C),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Detail',
                    style: TextStyle(fontWeight: FontWeight.w600),
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