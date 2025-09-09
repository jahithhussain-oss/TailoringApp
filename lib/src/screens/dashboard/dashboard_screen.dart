// dashboard_screen.dart
// UI for the main dashboard and shop selection/management.
import 'package:flutter/material.dart';
import '../../services/db_service.dart';
import '../customers/customers_screen.dart';
import '../orders/orders_screen.dart';
import '../measurements/measurements_screen.dart';
import '../shops/shops_screen.dart';
import '../item_types/item_types_screen.dart';
import '../orders/order_edit_screen.dart';
import '../login/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/google_sheets_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int pendingOrders = 0;
  int totalOrders = 0;
  int todaysOrders = 0;
  int customerCount = 0;
  bool _loading = true;
  GoogleSheetsService? _sheetsService;
  bool _syncing = false;

  @override
  void initState() {
    super.initState();
    _loadStats();
    _initSheetsService();
  }

  Future<void> _loadStats() async {
    setState(() => _loading = true);
    final orders = await DBService.getAllOrders();
    final customers = await DBService.getAllCustomers();
    final today = DateTime.now().toIso8601String().split('T').first;
    setState(() {
      totalOrders = orders.length;
      pendingOrders = orders
          .where((o) => (o['status'] ?? '').toLowerCase() == 'pending')
          .length;
      todaysOrders = orders
          .where((o) => (o['createdAt'] as String?)?.split('T').first == today)
          .length;
      customerCount = customers.length;
      _loading = false;
    });
  }

  Future<void> _initSheetsService() async {
    try {
      // TODO: Replace with your actual spreadsheet ID
      _sheetsService = GoogleSheetsService(
        'Google_Sheet_tailor.json',
        'your_spreadsheet_id', // Replace this with your actual Google Sheets ID
      );
      await _sheetsService!.init();
    } catch (e) {
      print('Failed to initialize Google Sheets service: $e');
      // Don't set _sheetsService to null, let the sync button show the error
    }
  }

  Future<String> _getLastSyncTime(String table) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('lastSync_$table') ?? '2000-01-01T00:00:00Z';
  }

  Future<void> _setLastSyncTime(String table, String newTime) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lastSync_$table', newTime);
  }

  Future<void> _testConnection() async {
    if (_sheetsService == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Google Sheets service not initialized. Check configuration.',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final result = await _sheetsService!.testConnection();

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Google Sheets Connection Test'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Status: ${result['status'] ?? 'Unknown'}'),
                if (result['spreadsheet_title'] != null)
                  Text('Spreadsheet: ${result['spreadsheet_title']}'),
                const SizedBox(height: 10),
                const Text(
                  'Worksheets:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                ...(result['worksheets'] as List<String>? ?? []).map(
                  (w) => Text('• $w'),
                ),
                if (result['error'] != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    'Error: ${result['error']}',
                    style: const TextStyle(color: Colors.red),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Test failed: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _syncAll() async {
    if (_sheetsService == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Google Sheets service not initialized. Check configuration.',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _syncing = true);

    try {
      final result = await _sheetsService!.syncAllData(
        getLastSyncTime: _getLastSyncTime,
        setLastSyncTime: _setLastSyncTime,
      );

      setState(() => _syncing = false);

      if (result['error'] != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sync failed: ${result['error']}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      } else {
        final successCount = result.entries
            .where((e) => e.value == 'ok')
            .length;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sync successful! Synced $successCount tables.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() => _syncing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sync error: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  void _showCreateOrderDialog() {
    _navigateTo(context, const OrderEditScreen());
  }

  @override
  Widget build(BuildContext context) {
    final red = const Color(0xFFDE3C2F);
    return Scaffold(
      backgroundColor: red,
      appBar: AppBar(
        backgroundColor: red,
        elevation: 0,
        title: const Text('Dashboard', style: TextStyle(color: Colors.white)),
        actions: [
          Theme(
            data: Theme.of(context).copyWith(
              popupMenuTheme: PopupMenuThemeData(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 8,
              ),
            ),
            child: PopupMenuButton<String>(
              icon: const Icon(Icons.grid_view_outlined, color: Colors.white),
              onSelected: (value) async {
                if (value == 'customers') {
                  _navigateTo(context, const CustomersScreen());
                } else if (value == 'orders') {
                  _navigateTo(context, const OrdersScreen());
                } else if (value == 'measurements') {
                  _navigateTo(context, const MeasurementsScreen());
                } else if (value == 'shops') {
                  _navigateTo(context, const ShopsScreen());
                } else if (value == 'item_types') {
                  _navigateTo(context, const ItemTypesScreen());
                } else if (value == 'create_order') {
                  _navigateTo(context, const OrderEditScreen());
                } else if (value == 'reset_database') {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Reset Database'),
                      content: const Text(
                        'This will delete all data and reset the database. This action cannot be undone. Are you sure?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Reset'),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    await DBService.resetDatabase();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Database reset successfully. Please restart the app.',
                        ),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'customers',
                  child: _MenuPopupItem(icon: Icons.people, label: 'Customers'),
                ),
                const PopupMenuDivider(),
                PopupMenuItem(
                  value: 'orders',
                  child: _MenuPopupItem(icon: Icons.list_alt, label: 'Orders'),
                ),
                const PopupMenuDivider(),
                PopupMenuItem(
                  value: 'measurements',
                  child: _MenuPopupItem(
                    icon: Icons.straighten,
                    label: 'Measurements',
                  ),
                ),
                const PopupMenuDivider(),
                PopupMenuItem(
                  value: 'shops',
                  child: _MenuPopupItem(icon: Icons.store, label: 'Shops'),
                ),
                const PopupMenuDivider(),
                PopupMenuItem(
                  value: 'item_types',
                  child: _MenuPopupItem(
                    icon: Icons.category,
                    label: 'Item Types',
                  ),
                ),
                const PopupMenuDivider(),
                PopupMenuItem(
                  value: 'reset_database',
                  child: _MenuPopupItem(
                    icon: Icons.refresh,
                    label: 'Reset Database',
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              // If using FirebaseAuth, sign out here
              // await FirebaseAuth.instance.signOut();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            tooltip: 'Logout',
          ),
        ],
      ),
      body: SafeArea(
        child: _loading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.white),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Four summary tiles
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 1.2,
                      children: [
                        _DashboardTile(
                          label: 'Pending Orders',
                          value: pendingOrders.toString(),
                          icon: Icons.pending_actions,
                        ),
                        _DashboardTile(
                          label: 'Total Orders',
                          value: totalOrders.toString(),
                          icon: Icons.list_alt,
                        ),
                        _DashboardTile(
                          label: "Today's Orders",
                          value: todaysOrders.toString(),
                          icon: Icons.today,
                        ),
                        _DashboardTile(
                          label: 'Customers',
                          value: customerCount.toString(),
                          icon: Icons.people,
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    // Create Order button
                    Center(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: red,
                          minimumSize: const Size(200, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        icon: const Icon(Icons.add),
                        label: const Text(
                          'Create Order',
                          style: TextStyle(fontSize: 18),
                        ),
                        onPressed: _showCreateOrderDialog,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(150, 48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          icon: const Icon(Icons.wifi_protected_setup),
                          label: const Text(
                            'Test Connection',
                            style: TextStyle(fontSize: 14),
                          ),
                          onPressed: _testConnection,
                        ),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(150, 48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          icon: _syncing
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.sync),
                          label: const Text(
                            'Sync Data',
                            style: TextStyle(fontSize: 14),
                          ),
                          onPressed: _syncing ? null : _syncAll,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _DashboardTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _DashboardTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white.withOpacity(0.9),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 65,
        height: 70,
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: const Color(0xFFDE3C2F), size: 24),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Color(0xFFDE3C2F),
              ),
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 10, color: Colors.black87),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuPopupItem extends StatelessWidget {
  final IconData icon;
  final String label;
  const _MenuPopupItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Color(0xFFDE3C2F)),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFFDE3C2F),
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}
