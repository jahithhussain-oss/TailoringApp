// measurements_screen.dart
// UI for taking and managing measurements.

import 'package:flutter/material.dart';
import '../../services/db_service.dart';

class MeasurementsScreen extends StatefulWidget {
  const MeasurementsScreen({super.key});

  @override
  State<MeasurementsScreen> createState() => _MeasurementsScreenState();
}

class _MeasurementsScreenState extends State<MeasurementsScreen> {
  List<Map<String, dynamic>> _measurements = [];
  List<Map<String, dynamic>> _filteredMeasurements = [];
  List<Map<String, dynamic>> _customers = [];
  bool _loading = true;
  final TextEditingController _searchController = TextEditingController();

  // Controllers for measurement fields
  final TextEditingController _lengthController = TextEditingController();
  final TextEditingController _shoulderController = TextEditingController();
  final TextEditingController _slLooseController = TextEditingController();
  final TextEditingController _armHoleController = TextEditingController();
  final TextEditingController _chestController = TextEditingController();
  final TextEditingController _hipController = TextEditingController();
  final TextEditingController _pointController = TextEditingController();
  final TextEditingController _seatController = TextEditingController();
  final TextEditingController _fNeckController = TextEditingController();
  final TextEditingController _bNeckController = TextEditingController();
  final TextEditingController _bottomLengthController = TextEditingController();
  final TextEditingController _bottomWaistController = TextEditingController();
  final TextEditingController _bottomController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadMeasurements();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _lengthController.dispose();
    _shoulderController.dispose();
    _slLooseController.dispose();
    _armHoleController.dispose();
    _chestController.dispose();
    _hipController.dispose();
    _pointController.dispose();
    _seatController.dispose();
    _fNeckController.dispose();
    _bNeckController.dispose();
    _bottomLengthController.dispose();
    _bottomWaistController.dispose();
    _bottomController.dispose();
    super.dispose();
  }

  Future<void> _loadMeasurements() async {
    setState(() => _loading = true);
    final measurements = await DBService.getAllMeasurements();
    final customers = await DBService.getAllCustomers();
    setState(() {
      _measurements = measurements;
      _customers = customers;
      _filteredMeasurements = measurements;
      _loading = false;
    });
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredMeasurements = _measurements.where((measurement) {
        final customer = _customers.firstWhere(
          (c) => c['id'] == measurement['customerId'],
          orElse: () => {'name': ''},
        );
        return (customer['name'] ?? '').toLowerCase().contains(query);
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

  Future<void> _addOrEditMeasurement({int? id}) async {
    final customerId = _selectedCustomerId;
    if (customerId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a customer')));
      return;
    }

    final data = {
      'customerId': customerId,
      'length': _lengthController.text.trim(),
      'shoulder': _shoulderController.text.trim(),
      'slLoose': _slLooseController.text.trim(),
      'armHole': _armHoleController.text.trim(),
      'chest': _chestController.text.trim(),
      'hip': _hipController.text.trim(),
      'point': _pointController.text.trim(),
      'seat': _seatController.text.trim(),
      'fNeck': _fNeckController.text.trim(),
      'bNeck': _bNeckController.text.trim(),
      'bottomLength': _bottomLengthController.text.trim(),
      'bottomWaist': _bottomWaistController.text.trim(),
      'bottom': _bottomController.text.trim(),
      'createdAt': DateTime.now().toIso8601String(),
    };

    try {
      if (id == null) {
        await DBService.insertMeasurement(data);
      } else {
        await DBService.updateMeasurement(id, data);
      }
      _clearControllers();
      Navigator.pop(context);
      await _loadMeasurements();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to save measurement: $e')));
    }
  }

  void _showAddOrEditMeasurementDialog({Map<String, dynamic>? measurement}) {
    if (measurement != null) {
      _selectedCustomerId = measurement['customerId'];
      _lengthController.text = measurement['length'] ?? '';
      _shoulderController.text = measurement['shoulder'] ?? '';
      _slLooseController.text = measurement['slLoose'] ?? '';
      _armHoleController.text = measurement['armHole'] ?? '';
      _chestController.text = measurement['chest'] ?? '';
      _hipController.text = measurement['hip'] ?? '';
      _pointController.text = measurement['point'] ?? '';
      _seatController.text = measurement['seat'] ?? '';
      _fNeckController.text = measurement['fNeck'] ?? '';
      _bNeckController.text = measurement['bNeck'] ?? '';
      _bottomLengthController.text = measurement['bottomLength'] ?? '';
      _bottomWaistController.text = measurement['bottomWaist'] ?? '';
      _bottomController.text = measurement['bottom'] ?? '';
    } else {
      _clearControllers();
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFDE3C2F),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          measurement == null ? 'Add Measurement' : 'Edit Measurement',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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
                style: const TextStyle(color: Colors.black),
                validator: (v) => v == null ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              _buildMeasurementField('Length', _lengthController),
              _buildMeasurementField('Shoulder', _shoulderController),
              _buildMeasurementField('SL Loose', _slLooseController),
              _buildMeasurementField('Arm Hole', _armHoleController),
              _buildMeasurementField('Chest', _chestController),
              _buildMeasurementField('Hip', _hipController),
              _buildMeasurementField('Point', _pointController),
              _buildMeasurementField('Seat', _seatController),
              _buildMeasurementField('F.Neck', _fNeckController),
              _buildMeasurementField('B.Neck', _bNeckController),
              _buildMeasurementField('Bottom Length', _bottomLengthController),
              _buildMeasurementField('Bottom Waist', _bottomWaistController),
              _buildMeasurementField('Bottom', _bottomController),
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
            onPressed: () => _addOrEditMeasurement(id: measurement?['id']),
            child: Text(measurement == null ? 'Add' : 'Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildMeasurementField(
    String label,
    TextEditingController controller,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
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
        ),
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  Future<void> _deleteMeasurement(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Measurement'),
        content: const Text(
          'Are you sure you want to delete this measurement?',
        ),
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
      await DBService.deleteMeasurement(id);
      await _loadMeasurements();
    }
  }

  void _clearControllers() {
    _selectedCustomerId = null;
    _lengthController.clear();
    _shoulderController.clear();
    _slLooseController.clear();
    _armHoleController.clear();
    _chestController.clear();
    _hipController.clear();
    _pointController.clear();
    _seatController.clear();
    _fNeckController.clear();
    _bNeckController.clear();
    _bottomLengthController.clear();
    _bottomWaistController.clear();
    _bottomController.clear();
  }

  int? _selectedCustomerId;

  @override
  Widget build(BuildContext context) {
    final red = const Color(0xFFDE3C2F);
    return Scaffold(
      backgroundColor: red,
      appBar: AppBar(
        backgroundColor: red,
        elevation: 0,
        title: const Text(
          'Measurements',
          style: TextStyle(color: Colors.white),
        ),
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
                      labelText: 'Search by customer name',
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
                  child: _filteredMeasurements.isEmpty
                      ? const Center(
                          child: Text(
                            'No measurements found',
                            style: TextStyle(color: Colors.white),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _filteredMeasurements.length,
                          itemBuilder: (context, index) {
                            final measurement = _filteredMeasurements[index];
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
                                  _getCustomerName(measurement['customerId']),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFDE3C2F),
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if ((measurement['length'] ?? '')
                                        .isNotEmpty)
                                      Text(
                                        'Length: ${measurement['length']}',
                                        style: const TextStyle(
                                          color: Colors.black87,
                                        ),
                                      ),
                                    if ((measurement['shoulder'] ?? '')
                                        .isNotEmpty)
                                      Text(
                                        'Shoulder: ${measurement['shoulder']}',
                                        style: const TextStyle(
                                          color: Colors.black87,
                                        ),
                                      ),
                                    if ((measurement['slLoose'] ?? '')
                                        .isNotEmpty)
                                      Text(
                                        'SL Loose: ${measurement['slLoose']}',
                                        style: const TextStyle(
                                          color: Colors.black87,
                                        ),
                                      ),
                                    if ((measurement['armHole'] ?? '')
                                        .isNotEmpty)
                                      Text(
                                        'Arm Hole: ${measurement['armHole']}',
                                        style: const TextStyle(
                                          color: Colors.black87,
                                        ),
                                      ),
                                    if ((measurement['chest'] ?? '').isNotEmpty)
                                      Text(
                                        'Chest: ${measurement['chest']}',
                                        style: const TextStyle(
                                          color: Colors.black87,
                                        ),
                                      ),
                                    if ((measurement['hip'] ?? '').isNotEmpty)
                                      Text(
                                        'Hip: ${measurement['hip']}',
                                        style: const TextStyle(
                                          color: Colors.black87,
                                        ),
                                      ),
                                    if ((measurement['point'] ?? '').isNotEmpty)
                                      Text(
                                        'Point: ${measurement['point']}',
                                        style: const TextStyle(
                                          color: Colors.black87,
                                        ),
                                      ),
                                    if ((measurement['seat'] ?? '').isNotEmpty)
                                      Text(
                                        'Seat: ${measurement['seat']}',
                                        style: const TextStyle(
                                          color: Colors.black87,
                                        ),
                                      ),
                                    if ((measurement['fNeck'] ?? '').isNotEmpty)
                                      Text(
                                        'F.Neck: ${measurement['fNeck']}',
                                        style: const TextStyle(
                                          color: Colors.black87,
                                        ),
                                      ),
                                    if ((measurement['bNeck'] ?? '').isNotEmpty)
                                      Text(
                                        'B.Neck: ${measurement['bNeck']}',
                                        style: const TextStyle(
                                          color: Colors.black87,
                                        ),
                                      ),
                                    if ((measurement['bottomLength'] ?? '')
                                        .isNotEmpty)
                                      Text(
                                        'Bottom Length: ${measurement['bottomLength']}',
                                        style: const TextStyle(
                                          color: Colors.black87,
                                        ),
                                      ),
                                    if ((measurement['bottomWaist'] ?? '')
                                        .isNotEmpty)
                                      Text(
                                        'Bottom Waist: ${measurement['bottomWaist']}',
                                        style: const TextStyle(
                                          color: Colors.black87,
                                        ),
                                      ),
                                    if ((measurement['bottom'] ?? '')
                                        .isNotEmpty)
                                      Text(
                                        'Bottom: ${measurement['bottom']}',
                                        style: const TextStyle(
                                          color: Colors.black87,
                                        ),
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
                                          _showAddOrEditMeasurementDialog(
                                            measurement: measurement,
                                          ),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      onPressed: () =>
                                          _deleteMeasurement(measurement['id']),
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
        onPressed: () => _showAddOrEditMeasurementDialog(),
        child: const Icon(Icons.add),
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
