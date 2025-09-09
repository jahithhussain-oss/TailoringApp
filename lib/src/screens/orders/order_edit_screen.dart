import 'package:flutter/material.dart';
import '../../services/db_service.dart';

class OrderEditScreen extends StatefulWidget {
  final Map<String, dynamic>? order;
  const OrderEditScreen({super.key, this.order});

  @override
  State<OrderEditScreen> createState() => _OrderEditScreenState();
}

class _OrderEditScreenState extends State<OrderEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _orderNumberController = TextEditingController();
  int? _selectedCustomerId;
  DateTime? _orderDate;
  DateTime? _dueDate;
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _noOfPsController = TextEditingController();
  final TextEditingController _totalPriceController = TextEditingController();
  String _orderStatus = 'Pending';

  final List<Map<String, dynamic>> _orderDetails = [];
  List<Map<String, dynamic>> _customers = [];
  List<Map<String, dynamic>> _itemTypes = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    final customers = await DBService.getAllCustomers();
    final itemTypes = await DBService.getAllItemTypes();
    setState(() {
      _customers = customers;
      _itemTypes = itemTypes;
      _loading = false;
    });
  }

  void _addOrEditDetail({Map<String, dynamic>? detail, int? index}) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) =>
          _OrderDetailDialog(itemTypes: _itemTypes, detail: detail),
    );
    if (result != null) {
      setState(() {
        if (index != null) {
          _orderDetails[index] = result;
        } else {
          _orderDetails.add(result);
        }
        _updateTotalPrice();
      });
    }
  }

  void _deleteDetail(int index) {
    setState(() {
      _orderDetails.removeAt(index);
      _updateTotalPrice();
    });
  }

  void _updateTotalPrice() {
    double total = 0;
    for (final d in _orderDetails) {
      final price = double.tryParse(d['price']?.toString() ?? '') ?? 0;
      total += price;
    }
    _totalPriceController.text = total.toStringAsFixed(2);
  }

  Future<void> _saveOrder() async {
    if (!_formKey.currentState!.validate() ||
        _selectedCustomerId == null ||
        _orderDate == null ||
        _dueDate == null) {
      return;
    }
    final orderData = {
      'orderNumber': _orderNumberController.text.trim(),
      'customerId': _selectedCustomerId,
      'orderDate': _orderDate!.toIso8601String(),
      'dueDate': _dueDate!.toIso8601String(),
      'location': _locationController.text.trim(),
      'noOfPs': int.tryParse(_noOfPsController.text.trim()) ?? 0,
      'totalPrice': double.tryParse(_totalPriceController.text.trim()) ?? 0,
      'status': _orderStatus,
      'totalPieces': _orderDetails.fold(
        0,
        (sum, detail) => sum + (detail['noOfPs'] as int? ?? 0),
      ),
      'createdAt': DateTime.now().toIso8601String(),
      'lastModified': DateTime.now().toIso8601String(),
    };
    final orderId = await DBService.insertOrder(orderData);
    for (final detail in _orderDetails) {
      final detailData = Map<String, dynamic>.from(detail);
      detailData['orderId'] = orderId;
      detailData['createdAt'] = DateTime.now().toIso8601String();
      detailData['lastModified'] = DateTime.now().toIso8601String();
      await DBService.insertOrderDetail(detailData);
    }
    await DBService.updateOrderTotalPieces(orderId);
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final red = const Color(0xFFDE3C2F);
    return Scaffold(
      backgroundColor: red,
      appBar: AppBar(
        backgroundColor: red,
        elevation: 0,
        title: const Text('Order', style: TextStyle(color: Colors.white)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Order Header
                    TextFormField(
                      controller: _orderNumberController,
                      decoration: _inputDecoration('Order Number *'),
                      style: const TextStyle(color: Colors.white),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<int>(
                      value: _selectedCustomerId,
                      items: _customers
                          .map(
                            (c) => DropdownMenuItem(
                              value: c['id'] as int,
                              child: Text(
                                c['name'],
                                style: const TextStyle(color: Colors.black),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _selectedCustomerId = v),
                      decoration: _inputDecoration('Customer *'),
                      validator: (v) => v == null ? 'Required' : null,
                      style: const TextStyle(color: Colors.black),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _DatePickerField(
                            label: 'Order Date *',
                            date: _orderDate,
                            onPick: (d) => setState(() => _orderDate = d),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _DatePickerField(
                            label: 'Due Date *',
                            date: _dueDate,
                            onPick: (d) => setState(() => _dueDate = d),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _locationController,
                      decoration: _inputDecoration('Location'),
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _orderStatus,
                      items: const [
                        DropdownMenuItem(
                          value: 'Pending',
                          child: Text('Pending'),
                        ),
                        DropdownMenuItem(
                          value: 'In Progress',
                          child: Text('In Progress'),
                        ),
                        DropdownMenuItem(
                          value: 'Completed',
                          child: Text('Completed'),
                        ),
                        DropdownMenuItem(
                          value: 'Cancelled',
                          child: Text('Cancelled'),
                        ),
                      ],
                      onChanged: (v) =>
                          setState(() => _orderStatus = v ?? 'Pending'),
                      decoration: _inputDecoration('Status'),
                      style: const TextStyle(color: Colors.black),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _noOfPsController,
                            decoration: _inputDecoration('No of Ps'),
                            style: const TextStyle(color: Colors.white),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _totalPriceController,
                            decoration: _inputDecoration('Total Price'),
                            style: const TextStyle(color: Colors.white),
                            keyboardType: TextInputType.number,
                            readOnly: true,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Order Details
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Order Details',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: red,
                          ),
                          icon: const Icon(Icons.add),
                          label: const Text('Add Detail'),
                          onPressed: () => _addOrEditDetail(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ..._orderDetails.asMap().entries.map((entry) {
                      final i = entry.key;
                      final d = entry.value;
                      final itemType = _itemTypes.firstWhere(
                        (it) => it['id'] == d['itemTypeId'],
                        orElse: () => {},
                      );
                      return Card(
                        color: Colors.white,
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          title: Text(
                            itemType['type'] ?? '',
                            style: const TextStyle(
                              color: Color(0xFFDE3C2F),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if ((d['itemDetail'] ?? '').toString().isNotEmpty)
                                Text(
                                  'Detail: ${d['itemDetail']}',
                                  style: const TextStyle(color: Colors.black87),
                                ),
                              Text('No of Ps: ${d['noOfPs'] ?? ''}'),
                              Text('Price: ₹${d['price'] ?? ''}'),
                              Text(
                                'Measurement: ${d['measurementType'] ?? ''}',
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.blue,
                                ),
                                onPressed: () =>
                                    _addOrEditDetail(detail: d, index: i),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () => _deleteDetail(i),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 32),
                    Center(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: red,
                          minimumSize: const Size(200, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: _saveOrder,
                        child: const Text(
                          'Save Order',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

InputDecoration _inputDecoration(String label) => InputDecoration(
  labelText: label,
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
);

class _DatePickerField extends StatelessWidget {
  final String label;
  final DateTime? date;
  final ValueChanged<DateTime> onPick;
  const _DatePickerField({
    required this.label,
    required this.date,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (picked != null) onPick(picked);
      },
      child: InputDecorator(
        decoration: _inputDecoration(label),
        child: Text(
          date == null
              ? ''
              : '${date!.year}-${date!.month.toString().padLeft(2, '0')}-${date!.day.toString().padLeft(2, '0')}',
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}

class _OrderDetailDialog extends StatefulWidget {
  final List<Map<String, dynamic>> itemTypes;
  final Map<String, dynamic>? detail;
  const _OrderDetailDialog({required this.itemTypes, this.detail});

  @override
  State<_OrderDetailDialog> createState() => _OrderDetailDialogState();
}

class _OrderDetailDialogState extends State<_OrderDetailDialog> {
  int? _selectedItemTypeId;
  final TextEditingController _itemDetailController = TextEditingController();
  final TextEditingController _noOfPsController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  String _measurementType = 'Same as sample';

  @override
  void initState() {
    super.initState();
    if (widget.detail != null) {
      _selectedItemTypeId = widget.detail!['itemTypeId'];
      _itemDetailController.text = widget.detail!['itemDetail'] ?? '';
      _noOfPsController.text = widget.detail!['noOfPs']?.toString() ?? '';
      _priceController.text = widget.detail!['price']?.toString() ?? '';
      _measurementType = widget.detail!['measurementType'] ?? 'Same as sample';
    }
  }

  @override
  Widget build(BuildContext context) {
    final red = const Color(0xFFDE3C2F);
    return AlertDialog(
      backgroundColor: red,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text(
        'Order Detail',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: _selectedItemTypeId,
                    items: widget.itemTypes
                        .map(
                          (it) => DropdownMenuItem(
                            value: it['id'] as int,
                            child: Text(
                              it['type'],
                              style: const TextStyle(color: Colors.black),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => _selectedItemTypeId = v),
                    decoration: _inputDecoration('Item Type *'),
                    validator: (v) => v == null ? 'Required' : null,
                    style: const TextStyle(color: Colors.black),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add, color: Colors.white),
                  onPressed: () {
                    // Optionally, implement inline add item type
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _itemDetailController,
              decoration: _inputDecoration('Item Detail'),
              style: const TextStyle(color: Colors.white),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _noOfPsController,
                    decoration: _inputDecoration('No of Ps'),
                    style: const TextStyle(color: Colors.white),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _priceController,
                    decoration: _inputDecoration('Price'),
                    style: const TextStyle(color: Colors.white),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _measurementType,
              items: const [
                DropdownMenuItem(
                  value: 'Same as sample',
                  child: Text('Same as sample'),
                ),
                DropdownMenuItem(
                  value: 'Custom measurement',
                  child: Text('Custom measurement'),
                ),
              ],
              onChanged: (v) =>
                  setState(() => _measurementType = v ?? 'Same as sample'),
              decoration: _inputDecoration('Measurement Type'),
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
            foregroundColor: red,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () {
            if (_selectedItemTypeId == null) return;
            Navigator.pop(context, {
              'itemTypeId': _selectedItemTypeId,
              'itemDetail': _itemDetailController.text.trim(),
              'noOfPs': int.tryParse(_noOfPsController.text.trim()) ?? 0,
              'price': double.tryParse(_priceController.text.trim()) ?? 0,
              'measurementType': _measurementType,
            });
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
