// customers_screen.dart
// UI for listing and managing customers.

import 'package:flutter/material.dart';
import '../../services/db_service.dart';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  List<Map<String, dynamic>> _customers = [];
  List<Map<String, dynamic>> _filteredCustomers = [];
  bool _loading = true;
  final TextEditingController _searchController = TextEditingController();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCustomers();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _loadCustomers() async {
    setState(() => _loading = true);
    try {
      final customers = await DBService.getAllCustomers();
      setState(() {
        _customers = customers;
        _filteredCustomers = customers;
        _loading = false;
      });
    } catch (e) {
      _showError('Failed to load customers:\n$e');
      setState(() => _loading = false);
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredCustomers = _customers.where((customer) {
        return (customer['name'] ?? '').toLowerCase().contains(query) ||
            (customer['phone'] ?? '').toLowerCase().contains(query);
      }).toList();
    });
  }

  Future<void> _addOrEditCustomer({int? id}) async {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final location = _locationController.text.trim();
    if (name.isEmpty || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }
    final data = {
      'name': name,
      'phone': phone,
      'location': location,
      'createdAt': DateTime.now().toIso8601String(),
      'lastModified': DateTime.now().toIso8601String(),
    };
    try {
      if (id == null) {
        await DBService.insertCustomer(data);
      } else {
        await DBService.updateCustomer(id, data);
      }
      _clearControllers();
      Navigator.pop(context);
      await _loadCustomers();
    } catch (e) {
      _showError('Failed to save customer: \n$e');
    }
  }

  void _showAddOrEditCustomerDialog({int? id}) {
    if (id != null) {
      final customer = _customers.firstWhere((c) => c['id'] == id);
      _nameController.text = customer['name'] ?? '';
      _phoneController.text = customer['phone'] ?? '';
      _locationController.text = customer['location'] ?? '';
    } else {
      _clearControllers();
    }
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFDE3C2F),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          id == null ? 'Add Customer' : 'Edit Customer',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Name *',
                  labelStyle: const TextStyle(color: Colors.white),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.white54),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.white),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  fillColor: Colors.white.withOpacity(0.1),
                  filled: true,
                ),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'Phone *',
                  labelStyle: const TextStyle(color: Colors.white),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.white54),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.white),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  fillColor: Colors.white.withOpacity(0.1),
                  filled: true,
                ),
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _locationController,
                decoration: InputDecoration(
                  labelText: 'Location (optional)',
                  labelStyle: const TextStyle(color: Colors.white),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.white54),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.white),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  fillColor: Colors.white.withOpacity(0.1),
                  filled: true,
                ),
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFFDE3C2F),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => _addOrEditCustomer(id: id),
            child: Text(id == null ? 'Add' : 'Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteCustomer(int id) async {
    try {
      await DBService.deleteCustomer(id);
      await _loadCustomers();
    } catch (e) {
      _showError('Failed to delete customer: \n$e');
    }
  }

  void _clearControllers() {
    _nameController.clear();
    _phoneController.clear();
    _locationController.clear();
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
    final red = const Color(0xFFDE3C2F);
    return Scaffold(
      backgroundColor: red,
      appBar: AppBar(
        backgroundColor: red,
        elevation: 0,
        title: const Text('Customers', style: TextStyle(color: Colors.white)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Search by name or phone',
                      labelStyle: const TextStyle(color: Colors.white),
                      prefixIcon: const Icon(Icons.search, color: Colors.white),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.white54),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      fillColor: Colors.white.withOpacity(0.1),
                      filled: true,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _filteredCustomers.length,
                    itemBuilder: (context, index) {
                      final customer = _filteredCustomers[index];
                      return Card(
                        color: Colors.white,
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          title: Text(
                            customer['name'] ?? '',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFDE3C2F),
                            ),
                          ),
                          subtitle: Text(
                            customer['phone'] ?? '',
                            style: const TextStyle(color: Colors.black87),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.blue,
                                ),
                                onPressed: () => _showAddOrEditCustomerDialog(
                                  id: customer['id'],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () =>
                                    _deleteCustomer(customer['id']),
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        foregroundColor: red,
        onPressed: () => _showAddOrEditCustomerDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
