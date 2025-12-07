import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cashierapp_simulationukk2026/models/pelanggan_models.dart';

class CustomerSelectorDialog extends StatefulWidget {
  const CustomerSelectorDialog({Key? key}) : super(key: key);

  @override
  State<CustomerSelectorDialog> createState() => _CustomerSelectorDialogState();
}

class _CustomerSelectorDialogState extends State<CustomerSelectorDialog> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _walkInNameController = TextEditingController();
  List<PelangganModel> _customers = [];
  List<PelangganModel> _filteredCustomers = [];
  bool _isLoading = true;
  bool _showWalkInInput = false;

  @override
  void initState() {
    super.initState();
    _loadCustomers();
    _searchController.addListener(_filterCustomers);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _walkInNameController.dispose();
    super.dispose();
  }

  Future<void> _loadCustomers() async {
    try {
      setState(() => _isLoading = true);

      final response = await Supabase.instance.client
          .from('pelanggan')
          .select()
          .order('namapelanggan', ascending: true);

      _customers = (response as List)
          .map(
            (json) => PelangganModel(
              pelangganID: json['pelangganid'],
              namaPelanggan: json['namapelanggan'],
              alamat: json['alamat'],
              nomorTelepon: json['nomortelepon'],
            ),
          )
          .toList();

      _filteredCustomers = _customers;

      if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint('Error loading customers: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _filterCustomers() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredCustomers = _customers.where((customer) {
        return customer.namaPelanggan.toLowerCase().contains(query) ||
            (customer.nomorTelepon?.toLowerCase().contains(query) ?? false);
      }).toList();
    });
  }

  void _toggleWalkIn() {
    setState(() {
      _showWalkInInput = !_showWalkInInput;
      if (!_showWalkInInput) {
        _walkInNameController.clear();
      }
    });
  }

  void _confirmWalkIn() {
    final name = _walkInNameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter customer name')),
      );
      return;
    }

    Navigator.pop(
      context,
      PelangganModel(
        pelangganID: 0,
        namaPelanggan: name,
        alamat: null,
        nomorTelepon: null,
      ),
    );
  }

  void _selectCustomer(PelangganModel customer) {
    Navigator.pop(context, customer);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => Navigator.pop(context),
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: GestureDetector(
          onTap: () {},
          child: Container(
            width: 390,
            height: 540,
            decoration: BoxDecoration(
              color: const Color(0xFF2E343B),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Column(
              children: [
                const SizedBox(height: 20),

                const Center(
                  child: Text(
                    'Choose Customer',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: _toggleWalkIn,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFF3A4C5E),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Walk In (New Member)',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        color: _showWalkInInput
                                            ? const Color(0xFFE4B169)
                                            : Colors.transparent,
                                        border: Border.all(
                                          color: _showWalkInInput
                                              ? const Color(0xFFE4B169)
                                              : Colors.white,
                                          width: 2,
                                        ),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: _showWalkInInput
                                          ? const Icon(
                                              Icons.check,
                                              color: Colors.white,
                                              size: 16,
                                            )
                                          : null,
                                    ),
                                  ],
                                ),

                                if (_showWalkInInput) ...[
                                  const SizedBox(height: 10),

                                  Row(
                                    children: [
                                      Expanded(
                                        child: Container(
                                          height: 40,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF25292E),
                                            borderRadius: BorderRadius.circular(
                                              25,
                                            ),
                                          ),
                                          child: TextField(
                                            controller: _walkInNameController,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 13,
                                            ),
                                            decoration: const InputDecoration(
                                              hintText: 'Enter customer name',
                                              hintStyle: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 12,
                                              ),
                                              border: InputBorder.none,
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                    horizontal: 14,
                                                  ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      GestureDetector(
                                        onTap: _confirmWalkIn,
                                        child: Container(
                                          width: 32,
                                          height: 32,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFE4B169),
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.check,
                                            color: Colors.white,
                                            size: 18,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        Row(
                          children: [
                            Expanded(
                              child: Divider(
                                color: Colors.grey[600],
                                thickness: 1,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              child: Text(
                                "Or",
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                color: Colors.grey[600],
                                thickness: 1,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        const Text(
                          'Member',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 14),

                        Container(
                          height: 42,
                          decoration: BoxDecoration(
                            color: const Color(0xFF25292E),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: TextField(
                            controller: _searchController,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                            decoration: const InputDecoration(
                              hintText: 'Search Member',
                              hintStyle: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                              prefixIcon: Icon(
                                Icons.search,
                                color: Colors.grey,
                                size: 20,
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.only(top: 10),
                            ),
                          ),
                        ),

                        const SizedBox(height: 18),

                        Expanded(
                          child: _isLoading
                              ? const Center(
                                  child: CircularProgressIndicator(
                                    color: Color(0xFFE4B169),
                                  ),
                                )
                              : _filteredCustomers.isEmpty
                              ? const Center(
                                  child: Text(
                                    'No customers found',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 14,
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: _filteredCustomers.length,
                                  itemBuilder: (context, index) {
                                    final customer = _filteredCustomers[index];

                                    return GestureDetector(
                                      onTap: () => _selectCustomer(customer),
                                      child: Container(
                                        padding: const EdgeInsets.all(14),
                                        margin: const EdgeInsets.only(
                                          bottom: 10,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF3A4C5E),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              customer.namaPelanggan,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            if (customer.nomorTelepon != null)
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  top: 4,
                                                ),
                                                child: Text(
                                                  customer.nomorTelepon!,
                                                  style: const TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 15),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
