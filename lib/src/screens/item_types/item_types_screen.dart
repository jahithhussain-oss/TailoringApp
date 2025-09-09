import 'package:flutter/material.dart';
import '../../services/db_service.dart';

class ItemTypesScreen extends StatefulWidget {
  const ItemTypesScreen({Key? key}) : super(key: key);

  @override
  State<ItemTypesScreen> createState() => _ItemTypesScreenState();
}

class _ItemTypesScreenState extends State<ItemTypesScreen> {
  List<Map<String, dynamic>> _itemTypes = [];
  bool _loading = true;
  final TextEditingController _typeController = TextEditingController();
  final TextEditingController _shortNameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadItemTypes();
  }

  @override
  void dispose() {
    _typeController.dispose();
    _shortNameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _loadItemTypes() async {
    setState(() => _loading = true);
    final items = await DBService.getAllItemTypes();
    setState(() {
      _itemTypes = items;
      _loading = false;
    });
  }

  void _showAddOrEditDialog({Map<String, dynamic>? itemType}) {
    if (itemType != null) {
      _typeController.text = itemType['type'] ?? '';
      _shortNameController.text = itemType['shortName'] ?? '';
      _descController.text = itemType['description'] ?? '';
    } else {
      _typeController.clear();
      _shortNameController.clear();
      _descController.clear();
    }
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFDE3C2F),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          itemType == null ? 'Add Item Type' : 'Edit Item Type',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (itemType != null)
                TextField(
                  enabled: false,
                  decoration: InputDecoration(
                    labelText: 'Item ID',
                    labelStyle: const TextStyle(color: Colors.white),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                  controller: TextEditingController(
                    text: itemType['id'].toString(),
                  ),
                ),
              if (itemType != null) const SizedBox(height: 12),
              TextField(
                controller: _typeController,
                decoration: InputDecoration(
                  labelText: 'Item Type *',
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
                controller: _shortNameController,
                decoration: InputDecoration(
                  labelText: 'Short Name *',
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
                controller: _descController,
                decoration: InputDecoration(
                  labelText: 'Description',
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
                maxLines: 2,
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
            onPressed: () async {
              final type = _typeController.text.trim();
              final shortName = _shortNameController.text.trim();
              final desc = _descController.text.trim();
              if (type.isEmpty || shortName.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please fill all required fields'),
                  ),
                );
                return;
              }
              final data = {
                'type': type,
                'shortName': shortName,
                'description': desc,
              };
              if (itemType == null) {
                await DBService.insertItemType(data);
              } else {
                await DBService.updateItemType(itemType['id'], data);
              }
              Navigator.pop(context);
              await _loadItemTypes();
            },
            child: Text(itemType == null ? 'Add' : 'Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteItemType(int id) async {
    await DBService.deleteItemType(id);
    await _loadItemTypes();
  }

  @override
  Widget build(BuildContext context) {
    final red = const Color(0xFFDE3C2F);
    return Scaffold(
      backgroundColor: red,
      appBar: AppBar(
        backgroundColor: red,
        elevation: 0,
        title: const Text('Item Types', style: TextStyle(color: Colors.white)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : _itemTypes.isEmpty
          ? const Center(
              child: Text(
                'No item types found',
                style: TextStyle(color: Colors.white),
              ),
            )
          : ListView.builder(
              itemCount: _itemTypes.length,
              itemBuilder: (context, index) {
                final item = _itemTypes[index];
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
                      item['type'] ?? '',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFDE3C2F),
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Short Name: ${item['shortName'] ?? ''}',
                          style: const TextStyle(color: Colors.black87),
                        ),
                        if ((item['description'] ?? '').isNotEmpty)
                          Text(
                            'Description: ${item['description']}',
                            style: const TextStyle(color: Colors.black54),
                          ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _showAddOrEditDialog(itemType: item),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteItemType(item['id']),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        foregroundColor: red,
        onPressed: () => _showAddOrEditDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
