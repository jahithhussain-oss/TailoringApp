// customer.dart
// Model class for customers.

class Customer {
  final int id;
  final String name;
  final String phone;
  final String location;
  final String createdAt;
  final String lastModified;

  Customer({
    required this.id,
    required this.name,
    required this.phone,
    required this.location,
    required this.createdAt,
    required this.lastModified,
  });

  factory Customer.fromMap(Map<String, dynamic> map) {
    return Customer(
      id: int.tryParse(map['id'].toString()) ?? 0,
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      location: map['location'] ?? '',
      createdAt: map['createdAt'] ?? '',
      lastModified: map['lastModified'] ?? map['createdAt'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'location': location,
      'createdAt': createdAt,
      'lastModified': lastModified,
    };
  }

  List<String> toSheetRow(List<String> headers) {
    return headers.map((h) => toMap()[h]?.toString() ?? '').toList();
  }

  static List<String> sheetHeaders = [
    'id',
    'name',
    'phone',
    'location',
    'createdAt',
    'lastModified',
  ];
}
