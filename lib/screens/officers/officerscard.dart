import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cashierapp_simulationukk2026/models/petugas_models.dart';
import 'package:cashierapp_simulationukk2026/services/officers_services.dart';
import 'package:cashierapp_simulationukk2026/widgets/search_bar.dart';
import 'package:cashierapp_simulationukk2026/screens/officers/addofficers.dart';
import 'package:cashierapp_simulationukk2026/widgets/confirm_dialog.dart';
import 'package:cashierapp_simulationukk2026/widgets/notification.dart';

class AddNewOfficersScreen extends StatefulWidget {
  const AddNewOfficersScreen({super.key});

  @override
  State<AddNewOfficersScreen> createState() => _AddNewOfficersScreenState();
}

class _AddNewOfficersScreenState extends State<AddNewOfficersScreen> {
  final TextEditingController _searchController = TextEditingController();
  final OfficerService _officerService = OfficerService();

  List<Officer> _officers = [];
  List<Officer> _filteredOfficers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOfficers();
    _searchController.addListener(_filterOfficers);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Load semua officers dari tabel users
  Future<void> _loadOfficers() async {
    try {
      setState(() => _isLoading = true);

      final officers = await _officerService.getAllOfficers();

      setState(() {
        _officers = officers;
        _filteredOfficers = officers;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading users: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  /// Filter officers berdasarkan search query
  void _filterOfficers() {
    final query = _searchController.text.toLowerCase().trim();
    
    setState(() {
      if (query.isEmpty) {
        _filteredOfficers = _officers;
      } else {
        _filteredOfficers = _officers.where((officer) {
          final email = officer.email.toLowerCase();
          return email.contains(query);
        }).toList();
      }
    });
  }

  /// Konfirmasi sebelum delete officer
  void _confirmDeleteOfficer(Officer officer) {
    showDialog(
      context: context,
      builder: (_) => ConfirmationDialog(
        logoAssetPath: "assets/images/lensoralogo.png",
        message:
            "Are You Sure Want to Delete This Officers?",
        onNoPressed: () => Navigator.pop(context),
        onYesPressed: () {
          Navigator.pop(context);
          _deleteOfficer(officer);
        },
      ),
    );
  }

  /// Delete officer dari database
  Future<void> _deleteOfficer(Officer officer) async {
    try {
      await _officerService.deleteOfficer(officer.id!);
      await _loadOfficers();

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => SuccessNotificationDialog(
            message:
                "User deleted successfully!\n\nLogin account for ${officer.email} has been removed.",
            onOkPressed: () => Navigator.pop(context),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  /// Tampilkan dialog untuk add officer
  Future<void> _showAddOfficerDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => const AddOfficerDialogWithAuth(),
    );

    // Refresh list jika berhasil add officer
    if (result == true) {
      _loadOfficers();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF25292E),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header dengan back button
              _buildHeader(),

              const SizedBox(height: 35),

              // Add New Button
              _buildAddButton(),

              const SizedBox(height: 20),

              // Search Bar
              _buildSearchBar(),

              const SizedBox(height: 20),

              // Officers count
              _buildOfficerCount(),

              const SizedBox(height: 10),

              // Officer List
              _buildOfficerList(),
            ],
          ),
        ),
      ),
    );
  }

  /// Widget: Header dengan back button
  Widget _buildHeader() {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
            size: 20,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          "Add New Officers",
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  /// Widget: Add New Button
  Widget _buildAddButton() {
    return Center(
      child: GestureDetector(
        onTap: _showAddOfficerDialog,
        child: Container(
          width: 383,
          height: 55,
          decoration: BoxDecoration(
            color: const Color(0xFF3A4C5E),
            borderRadius: BorderRadius.circular(50),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.person_add,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                "Add New User",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Widget: Search Bar
  Widget _buildSearchBar() {
    return Center(
      child: CustomSearchBar(
        hintText: 'Search by Email',
        controller: _searchController,
        onChanged: (value) => _filterOfficers(),
        backgroundColor: const Color(0xFF2E343B),
      ),
    );
  }

  /// Widget: Officer Count
  Widget _buildOfficerCount() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Text(
        "Total Users: ${_filteredOfficers.length}",
        style: GoogleFonts.poppins(
          color: Colors.white70,
          fontSize: 13,
        ),
      ),
    );
  }

  /// Widget: Officer List
  Widget _buildOfficerList() {
    return Expanded(
      child: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            )
          : _filteredOfficers.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  itemCount: _filteredOfficers.length,
                  itemBuilder: (context, index) {
                    final officer = _filteredOfficers[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildOfficerCard(officer),
                    );
                  },
                ),
    );
  }

  /// Widget: Empty State
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.people_outline,
            size: 60,
            color: Colors.white38,
          ),
          const SizedBox(height: 16),
          Text(
            _searchController.text.isEmpty
                ? "No users yet"
                : "No users found",
            style: GoogleFonts.poppins(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchController.text.isEmpty
                ? "Add your first user to get started"
                : "Try a different search term",
            style: GoogleFonts.poppins(
              color: Colors.white38,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  /// Widget: Officer Card
  Widget _buildOfficerCard(Officer officer) {
    final roleColor = Color(officer.roleColor);

    return Center(
      child: Container(
        width: 335,
        height: 110,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF3A4C5E),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left side - Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Email
                  Text(
                    officer.email,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 4),
                  
                  // Password (hidden)
                  Row(
                    children: [
                      const Icon(
                        Icons.lock_outline,
                        size: 12,
                        color: Colors.white70,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '••••••••',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.white70,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Role badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: roleColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      officer.displayRole, // 'Admin' atau 'Petugas'
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Right side - Delete button
            IconButton(
              onPressed: () => _confirmDeleteOfficer(officer),
              icon: const Icon(
                Icons.delete_outline,
                color: Colors.white70,
                size: 24,
              ),
              tooltip: 'Delete User',
            ),
          ],
        ),
      ),
    );
  }
}