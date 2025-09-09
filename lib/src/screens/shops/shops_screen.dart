// shops_screen.dart
// UI for managing multiple tailoring shops.

import 'package:flutter/material.dart';
import '../../services/db_service.dart';

class ShopsScreen extends StatefulWidget {
  const ShopsScreen({super.key});

  @override
  State<ShopsScreen> createState() => _ShopsScreenState();
}

class _ShopsScreenState extends State<ShopsScreen> {
  List<Map<String, dynamic>> _shops = [];
  List<Map<String, dynamic>> _filteredShops = [];
  bool _loading = true;
  final TextEditingController _searchController = TextEditingController();

  final TextEditingController _shopNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadShops();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _shopNameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadShops() async {
    setState(() => _loading = true);
    try {
      final shops = await DBService.getAllShops();
      setState(() {
        _shops = shops;
        _filteredShops = shops;
        _loading = false;
      });
    } catch (e) {
      _showError('Failed to load shops:\n$e');
      setState(() => _loading = false);
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredShops = _shops.where((shop) {
        return (shop['name'] ?? '').toLowerCase().contains(query) ||
            (shop['location'] ?? '').toLowerCase().contains(query) ||
            (shop['phone'] ?? '').toLowerCase().contains(query);
      }).toList();
    });
  }

  Future<void> _addOrEditShop({int? id}) async {
    final shopName = _shopNameController.text.trim();
    final address = _addressController.text.trim();
    final phone = _phoneController.text.trim();
    if (shopName.isEmpty || address.isEmpty || phone.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }
    final data = {
      'name': shopName,
      'location': address,
      'phone': phone,
      'createdAt': DateTime.now().toIso8601String(),
      'lastModified': DateTime.now().toIso8601String(),
    };
    try {
      if (id == null) {
        await DBService.insertShop(data);
      } else {
        await DBService.updateShop(id, data);
      }
      _clearControllers();
      Navigator.pop(context);
      await _loadShops();
    } catch (e) {
      _showError('Failed to save shop: \n$e');
    }
  }

  void _showAddOrEditShopDialog({int? id}) {
    if (id != null) {
      final shop = _shops.firstWhere((s) => s['id'] == id);
      _shopNameController.text = shop['name'] ?? '';
      _addressController.text = shop['location'] ?? '';
      _phoneController.text = shop['phone'] ?? '';
    } else {
      _clearControllers();
    }
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(id == null ? 'Add Shop' : 'Edit Shop'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _shopNameController,
                decoration: const InputDecoration(labelText: 'Shop Name'),
              ),
              TextField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Location'),
              ),
              TextField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone'),
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => _addOrEditShop(id: id),
            child: Text(id == null ? 'Add' : 'Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteShop(int id) async {
    try {
      await DBService.deleteShop(id);
      await _loadShops();
    } catch (e) {
      _showError('Failed to delete shop: \n$e');
    }
  }

  void _clearControllers() {
    _shopNameController.clear();
    _addressController.clear();
    _phoneController.clear();
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Shops')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search by shop name, location, or phone',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: _filteredShops.length,
                    itemBuilder: (context, index) {
                      final shop = _filteredShops[index];
                      return ListTile(
                        title: Text(shop['name'] ?? ''),
                        subtitle: Text(
                          'Location: ${shop['location'] ?? ''}\nPhone: ${shop['phone'] ?? ''}',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _showAddOrEditShopDialog(
                                id: shop['id'] as int,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Delete Shop'),
                                    content: const Text(
                                      'Are you sure you want to delete this shop?',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: const Text('Cancel'),
                                      ),
                                      ElevatedButton(
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red,
                                        ),
                                        child: const Text('Delete'),
                                      ),
                                    ],
                                  ),
                                );
                                if (confirm == true) {
                                  await _deleteShop(shop['id'] as int);
                                }
                              },
                            ),
                          ],
                        ),
                        onTap: () =>
                            _showAddOrEditShopDialog(id: shop['id'] as int),
                        leading: shop['createdAt'] != null
                            ? Text(
                                (shop['createdAt'] as String).split('T').first,
                              )
                            : null,
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddOrEditShopDialog(),
        tooltip: 'Add Shop',
        child: const Icon(Icons.add),
      ),
    );
  }
}
