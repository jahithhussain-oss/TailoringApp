// orders_screen.dart
// UI for listing and managing orders.

import 'package:flutter/material.dart';
import '../../services/db_service.dart';
import 'order_edit_screen.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  List<Map<String, dynamic>> _orders = [];
  List<Map<String, dynamic>> _filteredOrders = [];
  List<Map<String, dynamic>> _customers = [];
  bool _loading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadOrders();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadOrders() async {
    setState(() => _loading = true);
    final orders = await DBService.getAllOrders();
    final customers = await DBService.getAllCustomers();
    setState(() {
      _orders = orders;
      _customers = customers;
      _filteredOrders = orders;
      _loading = false;
    });
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredOrders = _orders.where((order) {
        final customer = _customers.firstWhere(
          (c) => c['id'] == order['customerId'],
          orElse: () => {'name': ''},
        );
        return (order['orderNumber'] ?? '').toLowerCase().contains(query) ||
            (customer['name'] ?? '').toLowerCase().contains(query);
      }).toList();
    });
  }

  String _getCustomerName(int customerId) {
    final customer = _customers.firstWhere(
      (c) => c['id'] == customerId,
      orElse: () => {'name': ''},
    );
    return customer['name'] ?? '';
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'Pending':
        return Colors.orange;
      case 'In Progress':
        return Colors.blue;
      case 'Completed':
        return Colors.green;
      case 'Cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _openOrder({Map<String, dynamic>? order}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => OrderEditScreen(order: order)),
    );
    if (result == true) {
      await _loadOrders();
    }
  }

  Future<void> _deleteOrder(int orderId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Order'),
        content: const Text('Are you sure you want to delete this order?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await DBService.deleteOrder(orderId);
      await _loadOrders();
    }
  }

  @override
  Widget build(BuildContext context) {
    final red = const Color(0xFFDE3C2F);
    return Scaffold(
      backgroundColor: red,
      appBar: AppBar(
        backgroundColor: red,
        elevation: 0,
        title: const Text('Orders', style: TextStyle(color: Colors.white)),
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
                      labelText: 'Search by order number or customer',
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
                  child: _filteredOrders.isEmpty
                      ? const Center(
                          child: Text(
                            'No orders found',
                            style: TextStyle(color: Colors.white),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _filteredOrders.length,
                          itemBuilder: (context, index) {
                            final order = _filteredOrders[index];
                            return Card(
                              color: Colors.white,
                              margin: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                title: Text(
                                  order['orderNumber'] ?? '',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFDE3C2F),
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Customer: ${_getCustomerName(order['customerId'])}',
                                      style: const TextStyle(
                                        color: Colors.black87,
                                      ),
                                    ),
                                    Text(
                                      'Order Date: ${order['orderDate']?.toString().split('T').first ?? ''}',
                                    ),
                                    Text(
                                      'Due Date: ${order['dueDate']?.toString().split('T').first ?? ''}',
                                    ),
                                    Text(
                                      'Status: ${order['status'] ?? 'Pending'}',
                                      style: TextStyle(
                                        color: _getStatusColor(order['status']),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'Total Pieces: ${order['totalPieces'] ?? 0}',
                                    ),
                                    Text(
                                      'Total Price: ₹${order['totalPrice'] ?? ''}',
                                    ),
                                  ],
                                ),
                                trailing: IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Colors.blue,
                                  ),
                                  onPressed: () => _openOrder(order: order),
                                ),
                                leading: IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () => _deleteOrder(order['id']),
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
        onPressed: () => _openOrder(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
