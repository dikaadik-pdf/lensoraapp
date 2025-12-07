import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cashierapp_simulationukk2026/screens/users/splash.dart';
import 'package:cashierapp_simulationukk2026/widgets/confirm_dialog.dart';
import 'package:cashierapp_simulationukk2026/widgets/notification.dart';
import 'package:intl/intl.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _salesNotification = true;
  bool _lowStockWarning = true;

  String _userName = 'Loading...';
  String _userEmail = 'Loading...';
  String _userRole = 'Loading...';
  String _createdAt = 'Loading...';
  bool _isLoading = true;
  bool _isLoggingOut = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

 Future<void> _loadUserData() async {
  setState(() => _isLoading = true);

  try {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      setState(() => _isLoading = false);
      return;
    }

    final response = await Supabase.instance.client
        .from('users')
        .select()
        .eq('id', user.id)
        .single();

    setState(() {
      // ✅ Ambil username dari email (sebelum @)
      _userName = user.email?.split('@').first.toUpperCase() ?? 'User';
      _userEmail = user.email ?? 'No email';
      _userRole = (response['role'] as String?)?.toLowerCase() ?? 'user';
      
      // ✅ Created at dari auth metadata
      final createdAt = user.createdAt;
      _createdAt = createdAt != null 
          ? DateFormat('dd MMM yyyy').format(DateTime.parse(createdAt))
          : '-';
          
      _isLoading = false;
    });
  } catch (e) {
    setState(() {
      _userName = 'Error loading profile';
      _userEmail = '';
      _userRole = 'user';
      _createdAt = '-';
      _isLoading = false;
    });
    print('Error loading user data: $e');
  }
}

  Future<void> _handleLogout() async {
    if (_isLoggingOut) return;
    setState(() => _isLoggingOut = true);

    try {
      await Supabase.instance.client.auth.signOut();

      if (!mounted) return;

      // Tampilkan success notification
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => SuccessNotificationDialog(
          message: "Sampai jumpa lagi!",
          onOkPressed: () {
            Navigator.pop(context); // Close dialog
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const SplashScreen()),
              (route) => false,
            );
          },
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Logout failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoggingOut = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF25292E),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadUserData,
          color: const Color(0xFFE4B169),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // HEADER
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios,
                          color: Colors.white, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text(
                      'Settings',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // USER INFO CARD
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3A4C5E),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 80,
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: Color(0xFFE4B169),
                                ),
                              ),
                            )
                          : Row(
                              children: [
                                // Avatar
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF2E343B),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.person,
                                      color: Colors.white, size: 32),
                                ),
                                const SizedBox(width: 16),
                                // Info
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _userRole.toUpperCase(),
                                        style: GoogleFonts.poppins(
                                          color: const Color(0xFFE4B169),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 1,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _userName,
                                        style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        _userEmail,
                                        style: GoogleFonts.poppins(
                                          color: Colors.white60,
                                          fontSize: 12,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Joined: $_createdAt',
                                        style: GoogleFonts.poppins(
                                          color: Colors.white70,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // NOTIFICATION SECTION
                Text(
                  'Notification',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 12),

                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3A4C5E),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Sales Notification
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.notifications_active,
                                      color: Color(0xFFE4B169), size: 20),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Sales Notification',
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              Switch(
                                value: _salesNotification,
                                onChanged: (v) => setState(
                                    () => _salesNotification = v),
                                activeColor: const Color(0xFFE4B169),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Divider(color: Colors.white.withOpacity(0.1)),
                          const SizedBox(height: 8),
                          // Low Stock Warning
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.warning_amber_rounded,
                                      color: Colors.redAccent, size: 20),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Low Stock Warning',
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              Switch(
                                value: _lowStockWarning,
                                onChanged: (v) =>
                                    setState(() => _lowStockWarning = v),
                                activeColor: Colors.redAccent,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // APP INFO
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2E343B).withOpacity(0.45),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Lensora Capture',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Copyright ©2026 CV. Lensora Company',
                            style: GoogleFonts.poppins(
                              color: Colors.white70,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Version 0.0.1 (Beta Version)',
                            style: GoogleFonts.poppins(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // LOGOUT BUTTON
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: SizedBox(
                      height: 50,
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoggingOut
                            ? null
                            : () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (_) => ConfirmationDialog(
                                    logoAssetPath: 'assets/images/lensoralogo.png',
                                    message: 'Are you sure you want to logout?',
                                    onNoPressed: () => Navigator.pop(context, false),
                                    onYesPressed: () => Navigator.pop(context, true),
                                  ),
                                );

                                if (confirm == true) _handleLogout();
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color(0xFFBF0505).withOpacity(0.45),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: _isLoggingOut
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.logout,
                                      color: Colors.white, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Log Out',
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
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}