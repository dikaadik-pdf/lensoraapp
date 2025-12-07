import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cashierapp_simulationukk2026/services/report_services.dart';
import 'package:cashierapp_simulationukk2026/services/export_services.dart';
import 'package:intl/intl.dart';

class ReportPrintScreen extends StatefulWidget {
  const ReportPrintScreen({Key? key}) : super(key: key);

  @override
  State<ReportPrintScreen> createState() => _ReportPrintScreenState();
}

class _ReportPrintScreenState extends State<ReportPrintScreen> {
  String _selectedPeriod = 'Daily';
  String _selectedCategory = 'Produk';
  bool _isLoading = false;
  List<Map<String, dynamic>> _reportData = [];

  final List<String> _periods = ['Daily', 'Weekly', 'Monthly'];

  @override
  void initState() {
    super.initState();
    _loadReport();
  }

  Future<void> _loadReport() async {
    setState(() => _isLoading = true);
    try {
      List<Map<String, dynamic>> data;

      if (_selectedCategory == 'Produk') {
        data = await ReportService.getProductReport(
          period: _selectedPeriod,
        );
      } else {
        data = await ReportService.getCustomerReport(
          period: _selectedPeriod,
        );
      }

      if (mounted) {
        setState(() {
          _reportData = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading report: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleExport() async {
    try {
      await ExportService.exportToPdf(
        reportData: _reportData,
        category: _selectedCategory,
        period: _selectedPeriod,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Report exported successfully'),
            backgroundColor: Color(0xFFE4B169),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error exporting: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handlePrint() async {
    try {
      await ExportService.printReport(
        reportData: _reportData,
        category: _selectedCategory,
        period: _selectedPeriod,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error printing: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF25292E),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // HEADER
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Text(
                    'Report & Print',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // PERIOD DROPDOWN
              _buildPeriodDropdown(),

              const SizedBox(height: 16),

              // CATEGORY TOGGLE
              _buildCategoryToggle(),

              const SizedBox(height: 16),

              // REPORT CONTAINER
              _buildReportContainer(),

              const SizedBox(height: 16),

              // EXPORT BUTTON
              _buildActionButton(
                label: 'Export',
                icon: Icons.file_download,
                onPressed: _handleExport,
              ),

              const SizedBox(height: 12),

              // PRINT BUTTON
              _buildActionButton(
                label: 'Print',
                icon: Icons.print,
                onPressed: _handlePrint,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPeriodDropdown() {
    return Center(
      child: Container(
        width: 360,
        height: 55,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF3A4C5E),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: _selectedPeriod,
            isExpanded: true,
            dropdownColor: const Color(0xFF3A4C5E),
            icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 16,
            ),
            items: _periods.map((String period) {
              return DropdownMenuItem<String>(
                value: period,
                child: Text(
                  period,
                  textAlign: TextAlign.center,
                ),
              );
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() => _selectedPeriod = newValue);
                _loadReport();
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryToggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildToggleButton('Produk', _selectedCategory == 'Produk'),
        const SizedBox(width: 12),
        _buildToggleButton('Customer', _selectedCategory == 'Customer'),
      ],
    );
  }

  Widget _buildToggleButton(String text, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() => _selectedCategory = text);
        _loadReport();
      },
      child: Container(
        width: 140,
        height: 40,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE4B169) : const Color(0xFF2E343B),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFFE4B169) : Colors.white24,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            text,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReportContainer() {
    return Center(
      child: Container(
        width: 390,
        height: 575,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF2E343B),
          borderRadius: BorderRadius.circular(6),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFFE4B169),
                ),
              )
            : _reportData.isEmpty
                ? Center(
                    child: Text(
                      'No data available',
                      style: GoogleFonts.poppins(
                        color: Colors.white54,
                        fontSize: 16,
                      ),
                    ),
                  )
                : ListView.separated(
                    itemCount: _reportData.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      if (_selectedCategory == 'Produk') {
                        return _buildProductReportItem(_reportData[index]);
                      } else {
                        return _buildCustomerReportItem(_reportData[index]);
                      }
                    },
                  ),
      ),
    );
  }

  Widget _buildProductReportItem(Map<String, dynamic> data) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF25292E),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            data['product_name'],
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Qty: ${data['quantity']}',
                style: GoogleFonts.poppins(
                  color: Colors.white70,
                  fontSize: 13,
                ),
              ),
              Text(
                'Rp ${NumberFormat('#,###', 'id_ID').format(data['subtotal'])}',
                style: GoogleFonts.poppins(
                  color: const Color(0xFFE4B169),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            dateFormat.format(data['tanggal']),
            style: GoogleFonts.poppins(
              color: Colors.white60,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Customer: ${data['customer']}',
            style: GoogleFonts.poppins(
              color: Colors.white60,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerReportItem(Map<String, dynamic> data) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF25292E),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            data['customer_name'],
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            data['phone'],
            style: GoogleFonts.poppins(
              color: Colors.white70,
              fontSize: 12,
              decoration: TextDecoration.underline,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Transactions',
                    style: GoogleFonts.poppins(
                      color: Colors.white60,
                      fontSize: 11,
                    ),
                  ),
                  Text(
                    '${data['transaction_count']}x',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Total Spending',
                    style: GoogleFonts.poppins(
                      color: Colors.white60,
                      fontSize: 11,
                    ),
                  ),
                  Text(
                    'Rp ${NumberFormat('#,###', 'id_ID').format(data['total_spending'])}',
                    style: GoogleFonts.poppins(
                      color: const Color(0xFFE4B169),
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Last: ${dateFormat.format(data['last_transaction'])}',
            style: GoogleFonts.poppins(
              color: Colors.white60,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Center(
      child: Container(
        width: 360,
        height: 55,
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
          borderRadius: BorderRadius.circular(25),
        ),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF3A4C5E),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
            elevation: 0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 24),
              const SizedBox(width: 12),
              Text(
                label,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
